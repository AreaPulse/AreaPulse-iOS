//
//  RegionStatsResponseDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 지역 통계 응답 DTO
struct RegionStatsResponseDTO: Codable {
    let regionStats: [RegionStats]
    let region: Region?
    
    enum CodingKeys: String, CodingKey {
        case regionStats = "region_stats"
        case region
    }
}
