//
//  AuthViewModel.swift
//  AreaPulse
//
//  Created by 바견규 on 12/01/24.
//

import Foundation
import Moya

/// 인증 관련 로직을 처리하는 ViewModel
@MainActor
class AuthViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var nickname: String = ""
    
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showError: Bool = false
    
    // MARK: - Private Properties
    
    private let apiService = MoyaAPIService.shared
    private let authManager = AuthManager.shared
    
    // MARK: - Public Methods
    
    /// 로그인 수행
    func login() async {
        guard validate(for: .login) else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. 로그인 API 호출
            let loginResponse = try await apiService.login(
                email: email,
                password: password
            )
            
            // 2. 사용자 정보 생성 (로그인 응답에는 사용자 정보가 없으므로 임시 생성)
            // 실제로는 토큰으로 사용자 정보를 조회하는 API가 필요할 수 있습니다
            let user = RegisterResponseDTO(
                userId: 0, // API에서 제공하지 않음
                email: email,
                nickname: "", // API에서 제공하지 않음
                createdAt: ""
            )
            
            // 3. AuthManager에 저장
            authManager.login(tokens: loginResponse, user: user)
            
            isLoading = false
            
        } catch {
            isLoading = false
            handleError(error)
        }
    }
    
    /// 회원가입 수행
    func register() async {
        guard validate(for: .register) else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. 회원가입 API 호출
            let registerResponse = try await apiService.register(
                email: email,
                password: password,
                nickname: nickname
            )
            
            // 2. 회원가입 성공 후 자동으로 로그인
            await login()
            
        } catch {
            isLoading = false
            handleError(error)
        }
    }
    
    /// 로그아웃 수행
    func logout() async {
        isLoading = true
        errorMessage = nil
        
        do {
            // 1. 로그아웃 API 호출
            _ = try await apiService.logout()
            
            // 2. AuthManager 상태 초기화
            authManager.logout()
            
            isLoading = false
            
        } catch {
            isLoading = false
            // 로그아웃은 실패해도 로컬 상태는 초기화
            authManager.logout()
            handleError(error)
        }
    }
    
    /// 토큰 갱신
    func refreshToken() async {
        guard let refreshToken = authManager.refreshToken else {
            errorMessage = "리프레시 토큰이 없습니다"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.refreshToken(refreshToken: refreshToken)
            authManager.refreshTokens(tokens: response)
            isLoading = false
        } catch {
            isLoading = false
            // 토큰 갱신 실패 시 로그아웃 처리
            authManager.logout()
            handleError(error)
        }
    }
    
    // MARK: - Private Methods
    
    /// 유효성 검사
    private func validate(for type: ValidationType) -> Bool {
        switch type {
        case .login:
            if email.isEmpty {
                showErrorMessage("이메일을 입력해주세요")
                return false
            }
            if password.isEmpty {
                showErrorMessage("비밀번호를 입력해주세요")
                return false
            }
            if !isValidEmail(email) {
                showErrorMessage("올바른 이메일 형식이 아닙니다")
                return false
            }
            
        case .register:
            if email.isEmpty {
                showErrorMessage("이메일을 입력해주세요")
                return false
            }
            if password.isEmpty {
                showErrorMessage("비밀번호를 입력해주세요")
                return false
            }
            if nickname.isEmpty {
                showErrorMessage("닉네임을 입력해주세요")
                return false
            }
            if !isValidEmail(email) {
                showErrorMessage("올바른 이메일 형식이 아닙니다")
                return false
            }
            if password.count < 6 {
                showErrorMessage("비밀번호는 6자 이상이어야 합니다")
                return false
            }
        }
        
        return true
    }
    
    /// 이메일 형식 검증
    private func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    /// 에러 메시지 표시
    private func showErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
    
    /// 에러 처리
    private func handleError(_ error: Error) {
        if let moyaError = error as? MoyaError {
            errorMessage = moyaError.localizedDescription
        } else {
            errorMessage = error.localizedDescription
        }
        showError = true
    }
    
    // MARK: - Helper Types
    
    private enum ValidationType {
        case login
        case register
    }
}
