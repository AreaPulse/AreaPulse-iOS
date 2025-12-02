//
//  SchoolType.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 학교 유형
enum SchoolType: String, Codable, CaseIterable {
    case elementary = "초등학교"
    case middle = "중학교"
    case high = "고등학교"
    case special = "특수학교"
    
    var displayName: String {
        return self.rawValue
    }
}
