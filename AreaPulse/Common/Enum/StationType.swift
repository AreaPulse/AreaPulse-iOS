//
//  StationType.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 환경 측정소 유형
enum StationType: String, Codable, CaseIterable {
    case airQuality = "air_quality"
    case noise = "noise"
    
    var displayName: String {
        switch self {
        case .airQuality: return "대기질"
        case .noise: return "소음"
        }
    }
}
