//
//  PointSearchResponseDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 좌표 검색 응답 DTO
struct PointSearchResponseDTO: Codable {
    let buildings: [Building]
    let infrastructure: [Infrastructure]
    let searchRadius: Int
    let resultCount: Int
    
    enum CodingKeys: String, CodingKey {
        case buildings
        case infrastructure
        case searchRadius = "search_radius"
        case resultCount = "result_count"
    }
}
