//
//  Environment.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation
import CoreLocation

/// 환경 측정소 모델 (T_ENVIRONMENT_STATION 테이블 대응)
struct EnvironmentStation: Identifiable, Codable, Hashable {
    let id: Int
    let stationType: StationType
    let stationName: String
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "station_id"
        case stationType = "station_type"
        case stationName = "station_name"
        case latitude
        case longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// 환경 데이터 모델 - API 응답에 맞게 재구성
struct EnvironmentData: Identifiable, Codable, Hashable {
    let address: String
    let noiseMax: Double
    let noiseAvg: Double
    let noiseMin: Double
    let latitude: Double
    let longitude: Double
    
    var id: String { address }
    
    enum CodingKeys: String, CodingKey {
        case address
        case noiseMax = "noise_max"
        case noiseAvg = "noise_avg"
        case noiseMin = "noise_min"
        case latitude
        case longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// 소음 등급
    var noiseGrade: String {
        switch noiseAvg {
        case 0..<50: return "조용함"
        case 50..<60: return "보통"
        case 60..<70: return "다소 시끄러움"
        case 70..<80: return "시끄러움"
        default: return "매우 시끄러움"
        }
    }
    
    /// 소음 등급 색상
    var noiseGradeColor: String {
        switch noiseAvg {
        case 0..<50: return "green"
        case 50..<60: return "blue"
        case 60..<70: return "yellow"
        case 70..<80: return "orange"
        default: return "red"
        }
    }
}
