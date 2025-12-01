//
//  RegisterView.swift
//  AreaPulse
//
//  Created by 바견규 on 12/01/24.
//

import SwiftUI

/// 회원가입 화면
struct RegisterView: View {
    
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 헤더
                    headerSection
                    
                    // 입력 필드
                    inputSection
                    
                    // 회원가입 버튼
                    registerButton
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 40)
            }
            .navigationTitle("회원가입")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
            .disabled(viewModel.isLoading)
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("오류", isPresented: $viewModel.showError) {
                Button("확인", role: .cancel) { }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
            .onChange(of: AuthManager.shared.isAuthenticated) { _, isAuthenticated in
                // 회원가입 성공 후 자동 로그인되면 화면 닫기
                if isAuthenticated {
                    dismiss()
                }
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "person.badge.plus")
                .font(.system(size: 50))
                .foregroundColor(.blue)
            
            Text("새 계정 만들기")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("AreaPulse에 가입하고 다양한 지역 정보를 확인하세요")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 24)
    }
    
    private var inputSection: some View {
        VStack(spacing: 16) {
            // 이메일
            VStack(alignment: .leading, spacing: 8) {
                Text("이메일")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("이메일을 입력하세요", text: $viewModel.email)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
                    .keyboardType(.emailAddress)
                    .autocorrectionDisabled()
            }
            
            // 비밀번호
            VStack(alignment: .leading, spacing: 8) {
                Text("비밀번호")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                SecureField("비밀번호를 입력하세요 (6자 이상)", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
            }
            
            // 닉네임
            VStack(alignment: .leading, spacing: 8) {
                Text("닉네임")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                TextField("닉네임을 입력하세요", text: $viewModel.nickname)
                    .textFieldStyle(.roundedBorder)
                    .autocorrectionDisabled()
            }
        }
    }
    
    private var registerButton: some View {
        Button {
            Task {
                await viewModel.register()
            }
        } label: {
            Text("회원가입")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .cornerRadius(12)
        }
        .padding(.top, 8)
    }
}

#Preview {
    RegisterView()
}
