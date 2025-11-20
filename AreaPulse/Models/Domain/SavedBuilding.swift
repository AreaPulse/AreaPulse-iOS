//
//  SavedBuilding.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 사용자 찜한 건물 모델 (T_USER_SAVED_BUILDING 테이블 대응)
struct SavedBuilding: Identifiable, Codable, Hashable {
    let id: Int
    let userId: Int
    let buildingId: Int
    let memo: String?
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "save_id"
        case userId = "user_id"
        case buildingId = "building_id"
        case memo
        case createdAt = "created_at"
    }
}
