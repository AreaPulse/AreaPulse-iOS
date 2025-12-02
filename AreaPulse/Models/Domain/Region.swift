//
//  Region.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 지역 정보 모델 (T_REGION 테이블 대응)
struct Region: Identifiable, Codable, Hashable {
    let bjdCode: String
    let regionNameFull: String
    let regionPolygon: String? // GeoJSON 형식의 문자열
    
    var id: String { bjdCode }
    
    enum CodingKeys: String, CodingKey {
        case bjdCode = "bjd_code"
        case regionNameFull = "region_name_full"
        case regionPolygon = "region_polygon"
    }
}

/// 지역 통계 모델 - API 응답에 맞게 재구성
struct RegionStats: Identifiable, Codable, Hashable {
    let regionName: String?
    let crimeNum: Int?
    let cctvNum: Int?
    let dangerousRating: Double?
    let cctvSecurityRating: Double?
    let passengerNum: Int?
    let complexityRating: Double?
    
    var id: String { regionName ?? UUID().uuidString }
    
    /// 통계 데이터가 유효한지 확인 (모든 필드가 nil이 아닌 경우)
    var hasValidData: Bool {
        crimeNum != nil || cctvNum != nil || dangerousRating != nil ||
        cctvSecurityRating != nil || passengerNum != nil || complexityRating != nil
    }
    
    enum CodingKeys: String, CodingKey {
        case regionName = "region_name"
        case crimeNum = "crime_num"
        case cctvNum = "cctv_num"
        case dangerousRating = "dangerous_rating"
        case cctvSecurityRating = "cctv_security_rating"
        case passengerNum = "passenger_num"
        case complexityRating = "complexity_rating"
    }
}
