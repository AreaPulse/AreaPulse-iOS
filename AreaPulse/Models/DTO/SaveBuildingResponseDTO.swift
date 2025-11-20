//
//  SaveBuildingResponseDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 건물 찜하기 응답 DTO
struct SaveBuildingResponseDTO: Codable {
    let saveId: Int
    let success: Bool
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case saveId = "save_id"
        case success
        case message
    }
}
