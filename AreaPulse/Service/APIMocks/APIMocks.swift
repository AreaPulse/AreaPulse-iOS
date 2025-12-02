//
//  AreaPulseAPIMocks.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// AreaPulse API용 Mock 데이터 집합
enum AreaPulseAPIMocks {
    
    static func sampleData(for target: AreaPulseAPI) -> Data {
        switch target {
        // MARK: - Auth
        case .register:
            return registerMockData()
        case .login:
            return loginMockData()
        case .refreshToken:
            return refreshTokenMockData()
        case .logout:
            return logoutMockData()
            
        // MARK: - Search
        case .pointSearch:
            return pointSearchMockData()
            
        // MARK: - Building
        case .buildingDetail(let buildingId):
            return buildingDetailMockData(buildingId: buildingId)
        case .buildingReviews:
            return buildingReviewsMockData()
            
        // MARK: - Review
        case .createReview:
            return createReviewMockData()
            
        // MARK: - Saved Building
        case .savedBuildings:
            return savedBuildingsMockData()
        case .saveBuilding(let buildingId, _):
            return saveBuildingMockData(buildingId: buildingId)
        case .deleteSavedBuilding:
            return successMockData()
            
        // MARK: - Infrastructure
        case .infrastructureByCategory:
            return infrastructureMockData()
            
        // MARK: - Region
        case .regionStats:
            return regionStatsMockData()
            
        // MARK: - Environment
        case .environmentData:
            return environmentDataMockData()
        }
    }
}

// MARK: - 실제 Mock JSON 생성부

private extension AreaPulseAPIMocks {
    
    // 공통 JSON → Data 변환
    static func toData(_ json: Any) -> Data {
        return try! JSONSerialization.data(withJSONObject: json)
    }
    
    // MARK: - Auth
    
    static func registerMockData() -> Data {
        let json: [String: Any] = [
            "user_id": Int.random(in: 1...1000),
            "email": "test@example.com",
            "nickname": "테스트유저",
            "created_at": ISO8601DateFormatter().string(from: Date())
        ]
        return toData(json)
    }
    
    static func loginMockData() -> Data {
        let json: [String: Any] = [
            "access_token": "mock_access_token_\(UUID().uuidString)",
            "refresh_token": "mock_refresh_token_\(UUID().uuidString)",
            "token_type": "bearer"
        ]
        return toData(json)
    }
    
    static func refreshTokenMockData() -> Data {
        let json: [String: Any] = [
            "access_token": "mock_access_token_\(UUID().uuidString)",
            "refresh_token": "mock_refresh_token_\(UUID().uuidString)",
            "token_type": "bearer"
        ]
        return toData(json)
    }
    
    static func logoutMockData() -> Data {
        let json: [String: Any] = [
            "message": "로그아웃되었습니다.",
            "user_id": 1
        ]
        return toData(json)
    }
    
    // MARK: - Building Detail
    
    static func buildingDetailMockData(buildingId: Int) -> Data {
        let mockBuildings: [[String: Any]] = [
            [
                "building_id": 1,
                "bjd_code": "1168010100",
                "address": "서울특별시 강남구 역삼동 123-45",
                "building_name": "강남 센트럴 아파트",
                "building_type": "아파트",
                "build_year": 2018,
                "total_units": 500,
                "latitude": 37.5007,
                "longitude": 127.0363
            ],
            [
                "building_id": 2,
                "bjd_code": "1168010100",
                "address": "서울특별시 강남구 역삼동 678-90",
                "building_name": "역삼 더샵 오피스텔",
                "building_type": "오피스텔",
                "build_year": 2020,
                "total_units": 300,
                "latitude": 37.5010,
                "longitude": 127.0370
            ],
            [
                "building_id": 3,
                "bjd_code": "1168010100",
                "address": "서울특별시 강남구 논현동 234-56",
                "building_name": "논현 빌라",
                "building_type": "빌라",
                "build_year": 2015,
                "total_units": 50,
                "latitude": 37.5100,
                "longitude": 127.0280
            ],
            [
                "building_id": 4,
                "bjd_code": "1165010100",
                "address": "서울특별시 서초구 서초동 456-78",
                "building_name": "서초 래미안 아파트",
                "building_type": "아파트",
                "build_year": 2019,
                "total_units": 800,
                "latitude": 37.4833,
                "longitude": 127.0324
            ],
            [
                "building_id": 5,
                "bjd_code": "1171010100",
                "address": "서울특별시 송파구 잠실동 123-45",
                "building_name": "잠실 트리지움",
                "building_type": "아파트",
                "build_year": 2021,
                "total_units": 1200,
                "latitude": 37.5134,
                "longitude": 127.1000
            ]
        ]
        
        let building = mockBuildings.first { ($0["building_id"] as? Int) == buildingId } ?? mockBuildings[0]
        let bjdCode = building["bjd_code"] as! String
        let basePrice = Int64(buildingId * 50000 + 100000)
        
        let json: [String: Any] = [
            "success": true,
            "building": building,
            "transactions": [
                [
                    "tx_id": buildingId * 100 + 1,
                    "building_id": buildingId,
                    "transaction_date": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 30)),
                    "price": basePrice,
                    "area_sqm": 84.5,
                    "floor": 12
                ],
                [
                    "tx_id": buildingId * 100 + 2,
                    "building_id": buildingId,
                    "transaction_date": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 90)),
                    "price": basePrice - 5000,
                    "area_sqm": 84.5,
                    "floor": 8
                ],
                [
                    "tx_id": buildingId * 100 + 3,
                    "building_id": buildingId,
                    "transaction_date": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 180)),
                    "price": basePrice - 8000,
                    "area_sqm": 59.5,
                    "floor": 5
                ]
            ],
            "reviews": [
                [
                    "review_id": buildingId * 100 + 1,
                    "user_id": 1,
                    "building_id": buildingId,
                    "rating": 5,
                    "content": "조용하고 깨끗한 환경입니다. 교통도 편리하고 주변 상권이 잘 형성되어 있어요.",
                    "created_at": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 10))
                ],
                [
                    "review_id": buildingId * 100 + 2,
                    "user_id": 2,
                    "building_id": buildingId,
                    "rating": 4,
                    "content": "단지 내 시설이 좋고 관리도 잘 되는 편입니다. 다만 주차가 조금 불편해요.",
                    "created_at": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 20))
                ],
                [
                    "review_id": buildingId * 100 + 3,
                    "user_id": 3,
                    "building_id": buildingId,
                    "rating": 5,
                    "content": "학군이 좋아서 만족스럽습니다. 주변에 공원도 가까워 아이 키우기 좋아요.",
                    "created_at": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 30))
                ]
            ],
            "nearby_infrastructure": [
                [
                    "infra_id": 1,
                    "infra_category": "school",
                    "name": "역삼초등학교",
                    "address": "서울특별시 강남구 역삼동 100",
                    "latitude": 37.5020,
                    "longitude": 127.0350
                ],
                [
                    "infra_id": 2,
                    "infra_category": "school",
                    "name": "역삼중학교",
                    "address": "서울특별시 강남구 역삼동 200",
                    "latitude": 37.5030,
                    "longitude": 127.0360
                ],
                [
                    "infra_id": 3,
                    "infra_category": "subway_station",
                    "name": "역삼역",
                    "address": "서울특별시 강남구 역삼동 지하",
                    "latitude": 37.5007,
                    "longitude": 127.0363
                ],
                [
                    "infra_id": 4,
                    "infra_category": "park",
                    "name": "역삼공원",
                    "address": "서울특별시 강남구 역삼동 300",
                    "latitude": 37.4990,
                    "longitude": 127.0340
                ],
                [
                    "infra_id": 5,
                    "infra_category": "hospital",
                    "name": "역삼병원",
                    "address": "서울특별시 강남구 역삼동 400",
                    "latitude": 37.5015,
                    "longitude": 127.0375
                ]
            ],
            "region_stats": [
                [
                    "stats_id": 1,
                    "bjd_code": bjdCode,
                    "stats_year": 2024,
                    "stats_type": "crime_total",
                    "stats_value": 45.0
                ],
                [
                    "stats_id": 2,
                    "bjd_code": bjdCode,
                    "stats_year": 2024,
                    "stats_type": "crime_theft",
                    "stats_value": 15.0
                ],
                [
                    "stats_id": 3,
                    "bjd_code": bjdCode,
                    "stats_year": 2024,
                    "stats_type": "noise_day",
                    "stats_value": 55.5
                ],
                [
                    "stats_id": 4,
                    "bjd_code": bjdCode,
                    "stats_year": 2024,
                    "stats_type": "noise_night",
                    "stats_value": 45.0
                ]
            ],
            "environment_data": [
                [
                    "data_id": 1,
                    "station_id": 1,
                    "measurement_time": ISO8601DateFormatter().string(from: Date()),
                    "pm10_value": 25,
                    "pm2_5_value": 12,
                    "noise_db": 55.5
                ]
            ]
        ]
        
        return toData(json)
    }
    
    // MARK: - Saved Buildings
    
    static func savedBuildingsMockData() -> Data {
        let mockBuildings: [[String: Any]] = [
            [
                "building_id": 1,
                "bjd_code": "1168010100",
                "address": "서울특별시 강남구 역삼동 123-45",
                "building_name": "강남 센트럴 아파트",
                "building_type": "아파트",
                "build_year": 2018,
                "total_units": 500,
                "latitude": 37.5007,
                "longitude": 127.0363
            ],
            [
                "building_id": 4,
                "bjd_code": "1165010100",
                "address": "서울특별시 서초구 서초동 456-78",
                "building_name": "서초 래미안 아파트",
                "building_type": "아파트",
                "build_year": 2019,
                "total_units": 800,
                "latitude": 37.4833,
                "longitude": 127.0324
            ]
        ]
        
        let json: [String: Any] = [
            "saved_buildings": [
                [
                    "save_id": 1,
                    "user_id": 1,
                    "building_id": 1,
                    "memo": "출퇴근 편리, 학군 좋음",
                    "created_at": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 5)),
                    "building": mockBuildings[0]
                ],
                [
                    "save_id": 2,
                    "user_id": 1,
                    "building_id": 4,
                    "memo": "가격대 적당, 재개발 예정지",
                    "created_at": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 10)),
                    "building": mockBuildings[1]
                ]
            ],
            "total_count": 2
        ]
        return toData(json)
    }
    
    static func saveBuildingMockData(buildingId: Int) -> Data {
        let json: [String: Any] = [
            "success": true,
            "save_id": Int.random(in: 100...999),
            "building_id": buildingId,
            "message": "찜하기 완료"
        ]
        return toData(json)
    }
    
    static func successMockData() -> Data {
        let json: [String: Any] = [
            "success": true,
            "message": "성공"
        ]
        return toData(json)
    }
    
    // MARK: - Building Reviews / Review
    
    static func buildingReviewsMockData() -> Data {
        let json: [String: Any] = [
            "reviews": [
                [
                    "review_id": 1,
                    "user_id": 1,
                    "building_id": 1,
                    "rating": 5,
                    "content": "조용하고 깨끗한 환경입니다. 교통도 편리하고 주변 상권이 잘 형성되어 있어요.",
                    "created_at": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 10))
                ],
                [
                    "review_id": 2,
                    "user_id": 2,
                    "building_id": 1,
                    "rating": 4,
                    "content": "단지 내 시설이 좋고 관리도 잘 되는 편입니다. 다만 주차가 조금 불편해요.",
                    "created_at": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 20))
                ],
                [
                    "review_id": 3,
                    "user_id": 3,
                    "building_id": 1,
                    "rating": 5,
                    "content": "학군이 좋아서 만족스럽습니다. 주변에 공원도 가까워 아이 키우기 좋아요.",
                    "created_at": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 30))
                ],
                [
                    "review_id": 4,
                    "user_id": 4,
                    "building_id": 1,
                    "rating": 3,
                    "content": "위치는 좋은데 건물이 좀 오래되어서 리모델링이 필요할 것 같아요.",
                    "created_at": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 45))
                ],
                [
                    "review_id": 5,
                    "user_id": 5,
                    "building_id": 1,
                    "rating": 4,
                    "content": "대중교통 접근성이 매우 좋습니다. 지하철역이 가까워서 출퇴근이 편리해요.",
                    "created_at": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-86400 * 60))
                ]
            ],
            "total_count": 5
        ]
        return toData(json)
    }
    
    static func createReviewMockData() -> Data {
        let json: [String: Any] = [
            "success": true,
            "review_id": Int.random(in: 1000...9999),
            "message": "리뷰가 등록되었습니다"
        ]
        return toData(json)
    }
    
    // MARK: - Point Search
    
    static func pointSearchMockData() -> Data {
        let buildings = [
            [
                "building_id": 1,
                "bjd_code": "1168010100",
                "address": "서울특별시 강남구 역삼동 123-45",
                "building_name": "강남 센트럴 아파트",
                "building_type": "아파트",
                "build_year": 2018,
                "total_units": 500,
                "latitude": 37.5007,
                "longitude": 127.0363
            ],
            [
                "building_id": 2,
                "bjd_code": "1168010100",
                "address": "서울특별시 강남구 역삼동 678-90",
                "building_name": "역삼 더샵 오피스텔",
                "building_type": "오피스텔",
                "build_year": 2020,
                "total_units": 300,
                "latitude": 37.5010,
                "longitude": 127.0370
            ],
            [
                "building_id": 3,
                "bjd_code": "1168010100",
                "address": "서울특별시 강남구 논현동 234-56",
                "building_name": "논현 빌라",
                "building_type": "빌라",
                "build_year": 2015,
                "total_units": 50,
                "latitude": 37.5100,
                "longitude": 127.0280
            ]
        ]
        
        let infrastructure = [
            [
                "infra_id": 1,
                "infra_category": "subway_station",
                "name": "역삼역",
                "address": "서울특별시 강남구 역삼동 지하",
                "latitude": 37.5007,
                "longitude": 127.0363
            ],
            [
                "infra_id": 2,
                "infra_category": "school",
                "name": "역삼초등학교",
                "address": "서울특별시 강남구 역삼동 100",
                "latitude": 37.5020,
                "longitude": 127.0350
            ],
            [
                "infra_id": 3,
                "infra_category": "hospital",
                "name": "강남세브란스병원",
                "address": "서울특별시 강남구 역삼동 500",
                "latitude": 37.5000,
                "longitude": 127.0380
            ],
            [
                "infra_id": 4,
                "infra_category": "mart",
                "name": "역삼 롯데마트",
                "address": "서울특별시 강남구 역삼동 300",
                "latitude": 37.5015,
                "longitude": 127.0355
            ]
        ]
        
        let json: [String: Any] = [
            "buildings": buildings,
            "infrastructure": infrastructure,
            "search_radius": 1000,
            "result_count": buildings.count + infrastructure.count
        ]
        return toData(json)
    }
    
    // MARK: - Infrastructure By Category
    
    static func infrastructureMockData() -> Data {
        let json: [String: Any] = [
            "infrastructure": [
                [
                    "infra_id": 1,
                    "infra_category": "subway_station",
                    "name": "역삼역 2호선",
                    "address": "서울특별시 강남구 역삼동 지하",
                    "latitude": 37.5007,
                    "longitude": 127.0363
                ],
                [
                    "infra_id": 2,
                    "infra_category": "subway_station",
                    "name": "강남역 2호선",
                    "address": "서울특별시 강남구 역삼동 지하",
                    "latitude": 37.4979,
                    "longitude": 127.0276
                ],
                [
                    "infra_id": 3,
                    "infra_category": "school",
                    "name": "역삼초등학교",
                    "address": "서울특별시 강남구 역삼동 100",
                    "latitude": 37.5020,
                    "longitude": 127.0350
                ],
                [
                    "infra_id": 4,
                    "infra_category": "school",
                    "name": "역삼중학교",
                    "address": "서울특별시 강남구 역삼동 200",
                    "latitude": 37.5030,
                    "longitude": 127.0360
                ],
                [
                    "infra_id": 5,
                    "infra_category": "school",
                    "name": "강남고등학교",
                    "address": "서울특별시 강남구 역삼동 300",
                    "latitude": 37.5040,
                    "longitude": 127.0370
                ],
                [
                    "infra_id": 6,
                    "infra_category": "hospital",
                    "name": "강남세브란스병원",
                    "address": "서울특별시 강남구 역삼동 500",
                    "latitude": 37.5000,
                    "longitude": 127.0380
                ],
                [
                    "infra_id": 7,
                    "infra_category": "hospital",
                    "name": "삼성서울병원",
                    "address": "서울특별시 강남구 일원동 81",
                    "latitude": 37.4885,
                    "longitude": 127.0857
                ],
                [
                    "infra_id": 8,
                    "infra_category": "mart",
                    "name": "역삼 롯데마트",
                    "address": "서울특별시 강남구 역삼동 300",
                    "latitude": 37.5015,
                    "longitude": 127.0355
                ],
                [
                    "infra_id": 9,
                    "infra_category": "mart",
                    "name": "코엑스몰",
                    "address": "서울특별시 강남구 삼성동 159",
                    "latitude": 37.5115,
                    "longitude": 127.0595
                ],
                [
                    "infra_id": 10,
                    "infra_category": "park",
                    "name": "선릉공원",
                    "address": "서울특별시 강남구 삼성동",
                    "latitude": 37.5048,
                    "longitude": 127.0493
                ],
                [
                    "infra_id": 11,
                    "infra_category": "park",
                    "name": "봉은사 근린공원",
                    "address": "서울특별시 강남구 삼성동",
                    "latitude": 37.5143,
                    "longitude": 127.0583
                ]
            ]
        ]
        return toData(json)
    }
    
    // MARK: - Region Stats
    
    static func regionStatsMockData() -> Data {
        let json: [String: Any] = [
            "region_stats": [
                [
                    "stats_id": 1,
                    "bjd_code": "1168010100",
                    "stats_year": 2024,
                    "stats_type": "crime_total",
                    "stats_value": 45.0
                ],
                [
                    "stats_id": 2,
                    "bjd_code": "1168010100",
                    "stats_year": 2024,
                    "stats_type": "crime_theft",
                    "stats_value": 15.0
                ],
                [
                    "stats_id": 3,
                    "bjd_code": "1168010100",
                    "stats_year": 2024,
                    "stats_type": "noise_day",
                    "stats_value": 55.5
                ],
                [
                    "stats_id": 4,
                    "bjd_code": "1168010100",
                    "stats_year": 2024,
                    "stats_type": "noise_night",
                    "stats_value": 45.0
                ]
            ],
            "region": [
                "bjd_code": "1168010100",
                "region_name_full": "서울특별시 강남구 역삼동"
            ]
        ]
        return toData(json)
    }
    
    // MARK: - Environment Data
    
    static func environmentDataMockData() -> Data {
        let json: [String: Any] = [
            "environment_data": [
                [
                    "data_id": 1,
                    "station_id": 1,
                    "measurement_time": ISO8601DateFormatter().string(from: Date()),
                    "pm10_value": 25,
                    "pm2_5_value": 12,
                    "noise_db": 55.5
                ],
                [
                    "data_id": 2,
                    "station_id": 1,
                    "measurement_time": ISO8601DateFormatter().string(from: Date().addingTimeInterval(-3600)),
                    "pm10_value": 30,
                    "pm2_5_value": 15,
                    "noise_db": 52.0
                ]
            ],
            "latitude": 37.5665,
            "longitude": 126.9780
        ]
        return toData(json)
    }
}
