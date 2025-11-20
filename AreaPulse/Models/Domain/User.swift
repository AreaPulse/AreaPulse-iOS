//
//  User.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 사용자 정보 모델 (T_USER 테이블 대응)
struct User: Identifiable, Codable, Hashable {
    let id: Int
    let email: String
    let passwordHash: String
    let nickname: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case email
        case passwordHash = "password_hash"
        case nickname
        case createdAt = "created_at"
    }
}
