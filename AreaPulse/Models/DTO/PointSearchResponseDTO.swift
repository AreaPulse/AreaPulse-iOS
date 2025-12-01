//
//  PointSearchResponseDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 12/01/24.
//

import Foundation

/// 포인트 검색 응답 DTO
struct PointSearchResponseDTO: Codable {
    let buildings: [Building]
    let infrastructure: [Infrastructure]
    let searchRadius: Int
    let resultCount: Int
    let regionStats: [RegionStats]?
    let environmentData: [EnvironmentData]?
    
    enum CodingKeys: String, CodingKey {
        case buildings
        case infrastructure
        case searchRadius = "search_radius"
        case resultCount = "result_count"
        case regionStats = "region_stats"
        case environmentData = "environment_data"
    }
}
