//
//  InfraCategory.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// 인프라 카테고리
enum InfraCategory: String, Codable, CaseIterable {
    case school = "school"
    case park = "park"
    case subwayStation = "subway_station"
    case busStop = "bus_stop"
    case hospital = "hospital"
    case mart = "mart"
    case bank = "bank"
    case publicOffice = "public_office"
    case cctv = "cctv"
    
    var displayName: String {
        switch self {
        case .school: return "학교"
        case .park: return "공원"
        case .subwayStation: return "지하철역"
        case .busStop: return "버스정류장"
        case .hospital: return "병원"
        case .mart: return "마트"
        case .bank: return "은행"
        case .publicOffice: return "관공서"
        case .cctv: return "CCTV"
        }
    }
    
    var iconName: String {
        switch self {
        case .school: return "building.2"
        case .park: return "leaf.fill"
        case .subwayStation: return "tram.fill"
        case .busStop: return "bus.fill"
        case .hospital: return "cross.case.fill"
        case .mart: return "cart.fill"
        case .bank: return "banknote.fill"
        case .publicOffice: return "building.columns.fill"
        case .cctv: return "video.fill"
        }
    }
    
    static let mapFilterCategories: [InfraCategory] = [
            .school,
            .subwayStation,
            .park
    ]
}
