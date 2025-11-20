//
//  BuildingReview.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 건물 리뷰 모델 (T_BUILDING_REVIEW 테이블 대응)
struct BuildingReview: Identifiable, Codable, Hashable {
    let id: Int
    let userId: Int
    let buildingId: Int
    let rating: Int
    let content: String
    let createdAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "review_id"
        case userId = "user_id"
        case buildingId = "building_id"
        case rating
        case content
        case createdAt = "created_at"
    }
}
