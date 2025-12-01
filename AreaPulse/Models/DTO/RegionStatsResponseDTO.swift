//
//  RegionStatsResponseDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 12/01/24.
//

import Foundation

/// 지역 통계 응답 DTO
struct RegionStatsResponseDTO: Codable {
    let regionStats: [RegionStat]
    let region: RegionInfo
    
    enum CodingKeys: String, CodingKey {
        case regionStats = "region_stats"
        case region
    }
}

/// 지역 통계 항목
struct RegionStat: Codable {
    let statsId: Int
    let bjdCode: String
    let statsYear: Int
    let statsType: String
    let statsValue: Double
    
    enum CodingKeys: String, CodingKey {
        case statsId = "stats_id"
        case bjdCode = "bjd_code"
        case statsYear = "stats_year"
        case statsType = "stats_type"
        case statsValue = "stats_value"
    }
}

/// 지역 정보
struct RegionInfo: Codable {
    let bjdCode: String
    let regionNameFull: String
    
    enum CodingKeys: String, CodingKey {
        case bjdCode = "bjd_code"
        case regionNameFull = "region_name_full"
    }
}
