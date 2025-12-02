//
//  AreaPulseAPI.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation
import Moya

/// AreaPulse API 엔드포인트 정의
enum AreaPulseAPI {
    // MARK: - Auth
    case register(email: String, password: String, nickname: String)
    case login(email: String, password: String)
    case refreshToken(refreshToken: String)
    case logout
    
    // MARK: - Search
    // 핀포인트 검색
    case pointSearch(latitude: Double, longitude: Double, radiusMeters: Int)
    
    // MARK: - Building
    // 건물 관련
    case buildingDetail(buildingId: Int)
    case buildingReviews(buildingId: Int)
    
    // MARK: - Review
    // 리뷰 관련
    case createReview(buildingId: Int, rating: Int, content: String)
    
    // MARK: - Saved Building
    // 찜하기 관련
    case savedBuildings
    case saveBuilding(buildingId: Int, memo: String?)
    case deleteSavedBuilding(saveId: Int)
    
    // MARK: - Infrastructure
    // 인프라 관련
    case infrastructureByCategory(category: InfraCategory, latitude: Double, longitude: Double, radiusMeters: Int)
    
    // MARK: - Region
    // 지역 통계
    case regionStats(bjdCode: String)
    
    // MARK: - Environment
    // 환경 데이터
    case environmentData(latitude: Double, longitude: Double)
}

extension AreaPulseAPI: TargetType {
    
    var baseURL: URL {
        return URL(string: "http://3.35.232.62:8000/api/v1")!
    }
    
    var path: String {
        switch self {
        case .register:
            return "/auth/register"
        case .login:
            return "/auth/login"
        case .refreshToken:
            return "/auth/refresh"
        case .logout:
            return "/auth/logout"
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
        case .environmentData:
            return "/environment/data"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .savedBuildings, .regionStats, .environmentData:
            return .get
        case .deleteSavedBuilding:
            return .delete
        default:
            return .post
        }
    }
    
    var task: Task {
        switch self {
        case .register(let email, let password, let nickname):
            let parameters: [String: Any] = [
                "email": email,
                "password": password,
                "nickname": nickname
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .login(let email, let password):
            // OAuth2 형식: application/x-www-form-urlencoded
            let parameters: [String: Any] = [
                "grant_type": "",
                "username": email,
                "password": password,
                "scope": "",
                "client_id": "",
                "client_secret": ""
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.default)
            
        case .refreshToken(let refreshToken):
            let parameters: [String: Any] = [
                "refresh_token": refreshToken
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .logout:
            return .requestPlain
            
        case .pointSearch(let latitude, let longitude, let radiusMeters):
            let parameters: [String: Any] = [
                "latitude": latitude,
                "longitude": longitude,
                "radius_meters": radiusMeters
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .buildingDetail(let buildingId):
            let parameters: [String: Any] = [
                "building_id": buildingId
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .buildingReviews(let buildingId):
            let parameters: [String: Any] = [
                "building_id": buildingId
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .createReview(let buildingId, let rating, let content):
            let parameters: [String: Any] = [
                "building_id": buildingId,
                "rating": rating,
                "content": content
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .savedBuildings:
            return .requestPlain

        case .saveBuilding(let buildingId, let memo):
            var parameters: [String: Any] = [
                "building_id": buildingId
            ]
            if let memo = memo {
                parameters["memo"] = memo
            }
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .deleteSavedBuilding(let saveId):
            let parameters: [String: Any] = [
                "save_id": saveId
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .infrastructureByCategory(let category, let latitude, let longitude, let radiusMeters):
            let parameters: [String: Any] = [
                "category": category.rawValue,
                "latitude": latitude,
                "longitude": longitude,
                "radius_meters": radiusMeters
            ]
            return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
            
        case .regionStats(let bjdCode):
            let parameters: [String: Any] = [
                "bjd_code": bjdCode
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
            
        case .environmentData(let latitude, let longitude):
            let parameters: [String: Any] = [
                "latitude": latitude,
                "longitude": longitude
            ]
            return .requestParameters(parameters: parameters, encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        var headers = [
            "Content-Type": "application/json",
            "Accept": "application/json"
        ]
        
        // Login은 OAuth2 형식이므로 Content-Type을 변경
        switch self {
        case .login:
            headers["Content-Type"] = "application/x-www-form-urlencoded"
        default:
            break
        }
        
        // 인증이 필요하지 않은 엔드포인트
        switch self {
        case .register, .login, .refreshToken:
            // 토큰 불필요
            break
        default:
            // 나머지는 모두 토큰 필요
            if let token = AuthManager.shared.accessToken {
                headers["Authorization"] = "Bearer \(token)"
            }
        }
        
        return headers
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
    
    /// Moya의 sampleData. DEBUG 에서만 실제 mock을 사용하고,
    /// Release에서는 빈 Data를 리턴하도록 분리.
    var sampleData: Data {
        return Data()
    }
}
