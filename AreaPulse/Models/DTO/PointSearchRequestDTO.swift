//
//  PointSearchRequestDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 핀포인트 검색 요청 DTO
struct PointSearchRequestDTO: Codable {
    let latitude: Double
    let longitude: Double
    let radiusMeters: Int // 검색 반경 (미터)
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
        case radiusMeters = "radius_meters"
    }
}
