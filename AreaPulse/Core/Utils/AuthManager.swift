//
//  AuthManager.swift
//  AreaPulse
//
//  Created by 바견규 on 12/01/24.
//

import Foundation

/// 인증 토큰 및 사용자 상태를 관리하는 싱글톤 매니저
@MainActor
class AuthManager: ObservableObject {
    
    static let shared = AuthManager()
    
    // MARK: - Published Properties
    
    /// 현재 로그인 여부
    @Published var isAuthenticated: Bool = false
    
    /// 현재 사용자 정보
    @Published var currentUser: RegisterResponseDTO?
    
    // MARK: - Private Properties
    
    /// UserDefaults 키
    private enum Keys {
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let userEmail = "userEmail"
        static let userNickname = "userNickname"
        static let userId = "userId"
        static let workplaceAddress = "workplaceAddress"
        static let workplaceLatitude = "workplaceLatitude"
        static let workplaceLongitude = "workplaceLongitude"
    }
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initialization
    
    private init() {
        // 앱 시작 시 저장된 토큰이 있는지 확인
        loadAuthState()
    }
    
    // MARK: - Public Methods
    
    /// 저장된 인증 상태를 불러옵니다
    func loadAuthState() {
        if let accessToken = accessToken,
           let userId = userDefaults.value(forKey: Keys.userId) as? Int,
           let email = userDefaults.string(forKey: Keys.userEmail),
           let nickname = userDefaults.string(forKey: Keys.userNickname) {
            
            isAuthenticated = !accessToken.isEmpty
            
            if isAuthenticated {
                currentUser = RegisterResponseDTO(
                    userId: userId,
                    email: email,
                    nickname: nickname,
                    createdAt: "" // 저장하지 않음
                )
            }
        } else {
            isAuthenticated = false
            currentUser = nil
        }
    }
    
    /// 로그인 성공 시 토큰과 사용자 정보를 저장합니다
    func login(tokens: LoginResponseDTO, user: RegisterResponseDTO) {
        // 토큰 저장
        userDefaults.set(tokens.accessToken, forKey: Keys.accessToken)
        userDefaults.set(tokens.refreshToken, forKey: Keys.refreshToken)
        
        // 사용자 정보 저장
        userDefaults.set(user.userId, forKey: Keys.userId)
        userDefaults.set(user.email, forKey: Keys.userEmail)
        userDefaults.set(user.nickname, forKey: Keys.userNickname)
        
        // 상태 업데이트
        isAuthenticated = true
        currentUser = user
    }
    
    /// 회원가입 성공 시 사용자 정보를 임시 저장합니다 (로그인은 별도로 필요)
    func register(user: RegisterResponseDTO) {
        // 회원가입 후 자동으로 로그인 처리하지 않음
        // 사용자가 로그인 화면에서 직접 로그인해야 함
    }
    
    /// 로그아웃 시 모든 인증 정보를 삭제합니다
    func logout() {
        userDefaults.removeObject(forKey: Keys.accessToken)
        userDefaults.removeObject(forKey: Keys.refreshToken)
        userDefaults.removeObject(forKey: Keys.userId)
        userDefaults.removeObject(forKey: Keys.userEmail)
        userDefaults.removeObject(forKey: Keys.userNickname)
        
        isAuthenticated = false
        currentUser = nil
    }
    
    /// 토큰을 갱신합니다
    func refreshTokens(tokens: RefreshTokenResponseDTO) {
        userDefaults.set(tokens.accessToken, forKey: Keys.accessToken)
        userDefaults.set(tokens.refreshToken, forKey: Keys.refreshToken)
    }
    
    // MARK: - Token Access
    
    /// 현재 저장된 Access Token
    nonisolated var accessToken: String? {
        return userDefaults.string(forKey: Keys.accessToken)
    }
    
    /// 현재 저장된 Refresh Token
    nonisolated var refreshToken: String? {
        return userDefaults.string(forKey: Keys.refreshToken)
    }
    
    /// Authorization 헤더 값 (Bearer 포함)
    nonisolated var authorizationHeader: String? {
        guard let token = accessToken else { return nil }
        return "Bearer \(token)"
    }
    
    // MARK: - Workplace Management
    
    /// 직장 주소 정보
    struct WorkplaceInfo: Codable {
        let address: String
        let latitude: Double
        let longitude: Double
    }
    
    /// 현재 저장된 직장 정보
    var workplaceInfo: WorkplaceInfo? {
        guard let address = userDefaults.string(forKey: Keys.workplaceAddress),
              let latitude = userDefaults.value(forKey: Keys.workplaceLatitude) as? Double,
              let longitude = userDefaults.value(forKey: Keys.workplaceLongitude) as? Double else {
            return nil
        }
        return WorkplaceInfo(address: address, latitude: latitude, longitude: longitude)
    }
    
    /// 직장 주소를 저장합니다
    func setWorkplace(address: String, latitude: Double, longitude: Double) {
        userDefaults.set(address, forKey: Keys.workplaceAddress)
        userDefaults.set(latitude, forKey: Keys.workplaceLatitude)
        userDefaults.set(longitude, forKey: Keys.workplaceLongitude)
    }
    
    /// 직장 주소를 삭제합니다
    func clearWorkplace() {
        userDefaults.removeObject(forKey: Keys.workplaceAddress)
        userDefaults.removeObject(forKey: Keys.workplaceLatitude)
        userDefaults.removeObject(forKey: Keys.workplaceLongitude)
    }
}
