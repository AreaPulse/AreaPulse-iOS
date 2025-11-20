//
//  BuildingReviewsResponseDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 건물 리뷰 목록 응답 DTO
struct BuildingReviewsResponseDTO: Codable {
    let reviews: [BuildingReview]
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case reviews
        case totalCount = "total_count"
    }
}
