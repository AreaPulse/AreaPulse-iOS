//
//  EnvironmentDataResponseDTO.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 환경 데이터 응답 DTO
struct EnvironmentDataResponseDTO: Codable {
    let environmentData: [EnvironmentData]
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case environmentData = "environment_data"
        case latitude
        case longitude
    }
}
