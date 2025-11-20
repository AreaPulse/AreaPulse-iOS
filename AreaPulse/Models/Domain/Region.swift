//
//  Region.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 지역 정보 모델 (T_REGION 테이블 대응)
struct Region: Identifiable, Codable, Hashable {
    let bjdCode: String
    let regionNameFull: String
    let regionPolygon: String? // GeoJSON 형식의 문자열
    
    var id: String { bjdCode }
    
    enum CodingKeys: String, CodingKey {
        case bjdCode = "bjd_code"
        case regionNameFull = "region_name_full"
        case regionPolygon = "region_polygon"
    }
}

/// 지역 통계 모델 (T_REGION_STATS 테이블 대응)
struct RegionStats: Identifiable, Codable, Hashable {
    let id: Int
    let bjdCode: String
    let statsYear: Int
    let statsType: StatsType
    let statsValue: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "stats_id"
        case bjdCode = "bjd_code"
        case statsYear = "stats_year"
        case statsType = "stats_type"
        case statsValue = "stats_value"
    }
}
