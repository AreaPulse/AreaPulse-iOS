//
//  LoginView.swift
//  AreaPulse
//
//  Created by 바견규 on 12/01/24.
//

import SwiftUI

/// 로그인 화면
struct LoginView: View {
    
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject private var authManager: AuthManager
    
    @State private var showRegisterView = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // 로고 및 타이틀
                    headerSection
                    
                    // 입력 필드
                    inputSection
                    
                    // 로그인 버튼
                    loginButton
                    
                    // 회원가입 링크
                    registerLink
                    
                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
            }
            .navigationTitle("로그인")
            .navigationBarTitleDisplayMode(.inline)
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
            .sheet(isPresented: $showRegisterView) {
                RegisterView()
            }
        }
    }
    
    // MARK: - View Components
    
    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "mappin.and.ellipse")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("AreaPulse")
                .font(.system(size: 32, weight: .bold))
            
            Text("지역 정보를 한눈에")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 40)
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
                
                SecureField("비밀번호를 입력하세요", text: $viewModel.password)
                    .textFieldStyle(.roundedBorder)
                    .textInputAutocapitalization(.never)
            }
        }
    }
    
    private var loginButton: some View {
        Button {
            Task {
                await viewModel.login()
            }
        } label: {
            Text("로그인")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.blue)
                .cornerRadius(12)
        }
        .padding(.top, 8)
    }
    
    private var registerLink: some View {
        Button {
            showRegisterView = true
        } label: {
            HStack(spacing: 4) {
                Text("계정이 없으신가요?")
                    .foregroundColor(.secondary)
                Text("회원가입")
                    .foregroundColor(.blue)
                    .fontWeight(.semibold)
            }
            .font(.subheadline)
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager.shared)
}
