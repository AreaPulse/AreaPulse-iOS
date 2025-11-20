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

/// 환경 데이터 모델 (T_ENVIRONMENT_DATA 테이블 대응)
struct EnvironmentData: Identifiable, Codable, Hashable {
    let id: Int
    let stationId: Int
    let measurementTime: Date
    let pm10Value: Int?
    let pm25Value: Int?
    let noiseDb: Double?
    
    enum CodingKeys: String, CodingKey {
        case id = "data_id"
        case stationId = "station_id"
        case measurementTime = "measurement_time"
        case pm10Value = "pm10_value"
        case pm25Value = "pm2_5_value"
        case noiseDb = "noise_db"
    }
    
    /// 미세먼지 등급
    var pm10Grade: String {
        guard let value = pm10Value else { return "정보없음" }
        switch value {
        case 0...30: return "좋음"
        case 31...80: return "보통"
        case 81...150: return "나쁨"
        default: return "매우나쁨"
        }
    }
    
    /// 초미세먼지 등급
    var pm25Grade: String {
        guard let value = pm25Value else { return "정보없음" }
        switch value {
        case 0...15: return "좋음"
        case 16...35: return "보통"
        case 36...75: return "나쁨"
        default: return "매우나쁨"
        }
    }
}
