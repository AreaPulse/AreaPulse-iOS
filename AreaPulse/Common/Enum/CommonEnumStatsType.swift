//
//  StatsType.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 지역 통계 유형
enum StatsType: String, Codable, CaseIterable {
    case crimeTotal = "crime_total"
    case crimeTheft = "crime_theft"
    case noiseDay = "noise_day"
    case noiseNight = "noise_night"
    
    var displayName: String {
        switch self {
        case .crimeTotal: return "총 범죄율"
        case .crimeTheft: return "절도 범죄"
        case .noiseDay: return "주간 소음"
        case .noiseNight: return "야간 소음"
        }
    }
    
    var unit: String {
        switch self {
        case .crimeTotal, .crimeTheft: return "건"
        case .noiseDay, .noiseNight: return "dB"
        }
    }
}
