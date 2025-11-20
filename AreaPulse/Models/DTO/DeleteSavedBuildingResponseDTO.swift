//
//  DeleteSavedBuildingResponseDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 찜한 건물 삭제 응답 DTO
struct DeleteSavedBuildingResponseDTO: Codable {
    let success: Bool
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case success
        case message
    }
}
