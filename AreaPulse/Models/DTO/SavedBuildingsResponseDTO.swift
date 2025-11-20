//
//  SavedBuildingsResponseDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 찜한 건물 목록 응답 DTO
struct SavedBuildingsResponseDTO: Codable {
    let savedBuildings: [SavedBuildingDetail]
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case savedBuildings = "saved_buildings"
        case totalCount = "total_count"
    }
}

/// 찜한 건물 상세 정보 (SavedBuilding + Building 정보 결합)
struct SavedBuildingDetail: Codable, Identifiable {
    let id: Int
    let userId: Int
    let buildingId: Int
    let memo: String?
    let createdAt: Date
    let building: Building
    
    enum CodingKeys: String, CodingKey {
        case id = "save_id"
        case userId = "user_id"
        case buildingId = "building_id"
        case memo
        case createdAt = "created_at"
        case building
    }
}
