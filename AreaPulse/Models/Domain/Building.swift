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
    let bjdCode: Int?  // Optional - 일부 API 응답에서 누락될 수 있음
    let address: String?
    let buildingName: String?
    let buildingType: BuildingType
    let buildYear: Int?
    let totalUnits: Int?
    let latitude: Double?  // Optional - 일부 API 응답에서 누락될 수 있음
    let longitude: Double?  // Optional - 일부 API 응답에서 누락될 수 있음
    
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
    
    // Custom decoder to handle both String and Int for buildYear and totalUnits
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(Int.self, forKey: .id)
        bjdCode = try container.decodeIfPresent(Int.self, forKey: .bjdCode)
        address = try container.decodeIfPresent(String.self, forKey: .address)
        buildingName = try container.decodeIfPresent(String.self, forKey: .buildingName)
        buildingType = try container.decode(BuildingType.self, forKey: .buildingType)
        latitude = try container.decodeIfPresent(Double.self, forKey: .latitude)
        longitude = try container.decodeIfPresent(Double.self, forKey: .longitude)
        
        // Handle buildYear as either String or Int
        if let yearInt = try? container.decodeIfPresent(Int.self, forKey: .buildYear) {
            buildYear = yearInt
        } else if let yearString = try? container.decodeIfPresent(String.self, forKey: .buildYear) {
            buildYear = Int(yearString)
        } else {
            buildYear = nil
        }
        
        // Handle totalUnits as either String or Int
        if let unitsInt = try? container.decodeIfPresent(Int.self, forKey: .totalUnits) {
            totalUnits = unitsInt
        } else if let unitsString = try? container.decodeIfPresent(String.self, forKey: .totalUnits) {
            totalUnits = Int(unitsString)
        } else {
            totalUnits = nil
        }
    }
    
    // Regular initializer for creating instances manually (e.g., in previews)
    init(id: Int, bjdCode: Int?, address: String?, buildingName: String?, buildingType: BuildingType, buildYear: Int?, totalUnits: Int?, latitude: Double?, longitude: Double?) {
        self.id = id
        self.bjdCode = bjdCode
        self.address = address
        self.buildingName = buildingName
        self.buildingType = buildingType
        self.buildYear = buildYear
        self.totalUnits = totalUnits
        self.latitude = latitude
        self.longitude = longitude
    }
    
    /// 좌표 (latitude, longitude가 있을 때만 유효)
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(
            latitude: latitude ?? 0,
            longitude: longitude ?? 0
        )
    }
    
    /// 좌표가 유효한지 확인
    var hasValidCoordinate: Bool {
        latitude != nil && longitude != nil
    }
}
