//
//  APIConfiguration.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// API 기본 설정
enum APIConfiguration {
    static let baseURL = "https://your-api-server.com/api/v1"
    static let timeout: TimeInterval = 30
    
    /// API 엔드포인트
    enum Endpoint {
        case pointSearch
        case buildingDetail
        case buildingReviews
        case createReview
        case savedBuildings
        case saveBuilding
        case deleteSavedBuilding
        case infrastructureByCategory
        case regionStats
        
        var path: String {
            switch self {
            case .pointSearch:
                return "/search/point"
            case .buildingDetail:
                return "/buildings/detail"
            case .buildingReviews:
                return "/buildings/reviews"
            case .createReview:
                return "/reviews/create"
            case .savedBuildings:
                return "/user/saved-buildings"
            case .saveBuilding:
                return "/user/save-building"
            case .deleteSavedBuilding:
                return "/user/delete-saved-building"
            case .infrastructureByCategory:
                return "/infrastructure/category"
            case .regionStats:
                return "/region/stats"
            }
        }
    }
}
