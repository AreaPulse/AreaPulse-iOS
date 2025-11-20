//
//  Building.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation
import CoreLocation

/// 건물 정보 모델 (T_BUILDING 테이블 대응)
struct Building: Identifiable, Codable, Hashable {
    let id: Int
    let bjdCode: String
    let address: String
    let buildingName: String?
    let buildingType: BuildingType
    let buildYear: Int?
    let totalUnits: Int?
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case id = "building_id"
        case bjdCode = "bjd_code"
        case address
        case buildingName = "building_name"
        case buildingType = "building_type"
        case buildYear = "build_year"
        case totalUnits = "total_units"
        case latitude
        case longitude
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
