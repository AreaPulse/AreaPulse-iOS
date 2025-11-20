//
//  BuildingReviewRequestDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 리뷰 작성 요청 DTO
struct CreateReviewRequestDTO: Codable {
    let buildingId: Int
    let rating: Int
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case buildingId = "building_id"
        case rating
        case content
    }
}

/// 리뷰 작성 응답 DTO
struct CreateReviewResponseDTO: Codable {
    let reviewId: Int
    let success: Bool
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case reviewId = "review_id"
        case success
        case message
    }
}
