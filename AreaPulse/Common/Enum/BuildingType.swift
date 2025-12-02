//
//  BuildingType.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 건물 유형
enum BuildingType: String, Codable, CaseIterable {
    case apartment = "아파트"
    case officetel = "오피스텔"
    case villa = "빌라"
    case rowHouse = "연립다세대"
    case house = "단독주택"
    case commercial = "상가"
    
    var displayName: String {
        return self.rawValue
    }
}
