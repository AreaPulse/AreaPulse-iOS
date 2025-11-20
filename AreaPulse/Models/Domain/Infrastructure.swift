//
//  Infrastructure.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation
import CoreLocation

/// 인프라 정보 모델 (T_INFRASTRUCTURE 테이블 대응)
struct Infrastructure: Identifiable, Codable, Hashable {
    let id: Int
    let category: InfraCategory
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "infra_id"
        case category = "infra_category"
        case name
        case address
        case latitude
        case longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

/// 학교 상세 정보 (T_SCHOOL_DETAIL 테이블 대응)
struct SchoolDetail: Codable, Hashable {
    let infraId: Int
    let schoolType: SchoolType
    let assignedDistrict: String?
    
    enum CodingKeys: String, CodingKey {
        case infraId = "infra_id"
        case schoolType = "school_type"
        case assignedDistrict = "assigned_district"
    }
}

/// 공원 상세 정보 (T_PARK_DETAIL 테이블 대응)
struct ParkDetail: Codable, Hashable {
    let infraId: Int
    let parkType: String
    let areaSqm: Double?
    
    enum CodingKeys: String, CodingKey {
        case infraId = "infra_id"
        case parkType = "park_type"
        case areaSqm = "area_sqm"
    }
}
