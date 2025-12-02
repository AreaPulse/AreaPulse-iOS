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
    let address: String?
    let latitude: Double
    let longitude: Double
    let extraData: [String: AnyCodable]?
    
    enum CodingKeys: String, CodingKey {
        case id = "infra_id"
        case category = "infra_category"
        case categoryType = "type"
        case name
        case address
        case latitude
        case longitude
        case extraData = "extra_data"
    }
    
    // Memberwise initializer for creating instances manually (e.g., in previews)
    init(id: Int, category: InfraCategory, name: String, address: String?, latitude: Double, longitude: Double, extraData: [String: AnyCodable]? = nil) {
        self.id = id
        self.category = category
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.extraData = extraData
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // ID는 infra_id가 있으면 사용하고, 없으면 해시값으로 생성
        if let infraId = try? container.decode(Int.self, forKey: .id) {
            self.id = infraId
        } else {
            // infra_id가 없는 경우 name, latitude, longitude로 해시 생성
            let name = try container.decode(String.self, forKey: .name)
            let lat = try container.decode(Double.self, forKey: .latitude)
            let lon = try container.decode(Double.self, forKey: .longitude)
            self.id = "\(name)-\(lat)-\(lon)".hashValue
        }
        
        // category는 infra_category 또는 type 필드에서 가져옴
        if let cat = try? container.decode(InfraCategory.self, forKey: .category) {
            self.category = cat
        } else {
            self.category = try container.decode(InfraCategory.self, forKey: .categoryType)
        }
        
        self.name = try container.decode(String.self, forKey: .name)
        self.address = try? container.decode(String.self, forKey: .address)
        self.latitude = try container.decode(Double.self, forKey: .latitude)
        self.longitude = try container.decode(Double.self, forKey: .longitude)
        self.extraData = try? container.decode([String: AnyCodable].self, forKey: .extraData)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(category, forKey: .category)
        try container.encode(name, forKey: .name)
        try container.encodeIfPresent(address, forKey: .address)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
        try container.encodeIfPresent(extraData, forKey: .extraData)
    }
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    // MARK: - Convenience Properties for extraData
    
    /// 혼잡도 등급 (1-10)
    var complexityRating: Int? {
        guard let extraData = extraData,
              let complexityValue = extraData["complexity_rating"]?.value as? Int else {
            return nil
        }
        return complexityValue
    }
    
    /// 승객 수
    var passengerNum: Int? {
        guard let extraData = extraData,
              let passengerValue = extraData["passenger_num"]?.value as? Int else {
            return nil
        }
        return passengerValue
    }
}

/// AnyCodable wrapper to handle dynamic JSON values
struct AnyCodable: Codable, Hashable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if let intValue = try? container.decode(Int.self) {
            value = intValue
        } else if let doubleValue = try? container.decode(Double.self) {
            value = doubleValue
        } else if let stringValue = try? container.decode(String.self) {
            value = stringValue
        } else if let boolValue = try? container.decode(Bool.self) {
            value = boolValue
        } else if let arrayValue = try? container.decode([AnyCodable].self) {
            value = arrayValue.map { $0.value }
        } else if let dictValue = try? container.decode([String: AnyCodable].self) {
            value = dictValue.mapValues { $0.value }
        } else if container.decodeNil() {
            value = Optional<Any>.none as Any
        } else {
            throw DecodingError.dataCorruptedError(
                in: container,
                debugDescription: "AnyCodable value cannot be decoded"
            )
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case let intValue as Int:
            try container.encode(intValue)
        case let doubleValue as Double:
            try container.encode(doubleValue)
        case let stringValue as String:
            try container.encode(stringValue)
        case let boolValue as Bool:
            try container.encode(boolValue)
        case let arrayValue as [Any]:
            try container.encode(arrayValue.map { AnyCodable($0) })
        case let dictValue as [String: Any]:
            try container.encode(dictValue.mapValues { AnyCodable($0) })
        case is Optional<Any>:
            try container.encodeNil()
        default:
            let context = EncodingError.Context(
                codingPath: container.codingPath,
                debugDescription: "AnyCodable value cannot be encoded"
            )
            throw EncodingError.invalidValue(value, context)
        }
    }
    
    func hash(into hasher: inout Hasher) {
        switch value {
        case let intValue as Int:
            hasher.combine(intValue)
        case let doubleValue as Double:
            hasher.combine(doubleValue)
        case let stringValue as String:
            hasher.combine(stringValue)
        case let boolValue as Bool:
            hasher.combine(boolValue)
        default:
            hasher.combine(0)
        }
    }
    
    static func == (lhs: AnyCodable, rhs: AnyCodable) -> Bool {
        switch (lhs.value, rhs.value) {
        case let (l as Int, r as Int):
            return l == r
        case let (l as Double, r as Double):
            return l == r
        case let (l as String, r as String):
            return l == r
        case let (l as Bool, r as Bool):
            return l == r
        default:
            return false
        }
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
