//
//  InfrastructureResponseDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 인프라 검색 응답 DTO
struct InfrastructureResponseDTO: Codable {
    let infrastructure: [Infrastructure]
    
    enum CodingKeys: String, CodingKey {
        case infrastructure
    }
}
