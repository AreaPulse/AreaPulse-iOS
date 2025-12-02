//
//  AuthRequestDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 12/01/24.
//

import Foundation

// MARK: - Register

/// 회원가입 요청 DTO
struct RegisterRequestDTO: Codable {
    let email: String
    let password: String
    let nickname: String
}

/// 회원가입 응답 DTO
struct RegisterResponseDTO: Codable {
    let userId: Int
    let email: String
    let nickname: String
    let createdAt: String
    
    enum CodingKeys: String, CodingKey {
        case userId = "user_id"
        case email
        case nickname
        case createdAt = "created_at"
    }
}

// MARK: - Login (OAuth2)

/// 로그인 응답 DTO
struct LoginResponseDTO: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}

// MARK: - Refresh Token

/// 토큰 갱신 요청 DTO
struct RefreshTokenRequestDTO: Codable {
    let refreshToken: String
    
    enum CodingKeys: String, CodingKey {
        case refreshToken = "refresh_token"
    }
}

/// 토큰 갱신 응답 DTO
struct RefreshTokenResponseDTO: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
        case tokenType = "token_type"
    }
}

// MARK: - Logout

/// 로그아웃 응답 DTO
struct LogoutResponseDTO: Codable {
    let message: String
    let userId: Int
    
    enum CodingKeys: String, CodingKey {
        case message
        case userId = "user_id"
    }
}
