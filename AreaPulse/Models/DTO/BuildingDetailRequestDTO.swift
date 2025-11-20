//
//  BuildingDetailRequestDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 건물 상세 정보 요청 DTO
struct BuildingDetailRequestDTO: Codable {
    let buildingId: Int
    
    enum CodingKeys: String, CodingKey {
        case buildingId = "building_id"
    }
}

/// 건물 상세 정보 응답 DTO
struct BuildingDetailResponseDTO: Codable {
    let building: Building
    let transactions: [RealEstateTransaction]
    let reviews: [BuildingReview]
    let nearbyInfrastructure: [Infrastructure]
    let regionStats: [RegionStats]
    let environmentData: [EnvironmentData]
    
    enum CodingKeys: String, CodingKey {
        case building
        case transactions
        case reviews
        case nearbyInfrastructure = "nearby_infrastructure"
        case regionStats = "region_stats"
        case environmentData = "environment_data"
    }
}
