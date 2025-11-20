//
//  MoyaAPIService.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation
import Moya

/// Moya 기반 API 서비스
/// AreaPulseAPI를 사용하여 실제 네트워크 요청을 수행합니다.
class MoyaAPIService {
    
    // MARK: - Properties
    
    static let shared = MoyaAPIService()
    
    private let provider: MoyaProvider<AreaPulseAPI>
    
    // MARK: - Mock 설정
    
    /// Mock 데이터 사용 여부
    /// true로 설정하면 실제 API 대신 sampleData를 반환합니다.
    /// API 구현 후 false로 변경하면 됩니다.
    static var useMockData: Bool = true // ⬅️ 여기만 false로 바꾸면 실제 API 사용!
    
    // MARK: - Initialization
    
    init(provider: MoyaProvider<AreaPulseAPI>? = nil) {
        if let provider = provider {
            self.provider = provider
        } else {
            // Mock 모드면 stubbing을 활성화
            if Self.useMockData {
                self.provider = MoyaProvider<AreaPulseAPI>(
                    stubClosure: { _ in .immediate }, // Mock 데이터를 즉시 반환
                    plugins: [
                        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
                    ]
                )
            } else {
                // 실제 API 모드
                self.provider = MoyaProvider<AreaPulseAPI>(
                    plugins: [
                        NetworkLoggerPlugin(configuration: .init(logOptions: .verbose))
                    ]
                )
            }
        }
    }
    
    // MARK: - Private Helper
    
    /// API 요청을 수행하고 응답을 디코딩합니다.
    private func request<T: Decodable>(_ target: AreaPulseAPI) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            provider.request(target) { result in
                switch result {
                case .success(let response):
                    do {
                        // 성공 상태 코드 확인
                        let filteredResponse = try response.filterSuccessfulStatusCodes()
                        
                        // JSON 디코딩
                        let decoder = JSONDecoder()
                        decoder.dateDecodingStrategy = .iso8601
                        let decodedData = try decoder.decode(T.self, from: filteredResponse.data)
                        
                        continuation.resume(returning: decodedData)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    // MARK: - API Methods
    
    /// 핀포인트 검색
    func searchPoint(
        latitude: Double,
        longitude: Double,
        radiusMeters: Int
    ) async throws -> PointSearchResponseDTO {
        return try await request(.pointSearch(
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters
        ))
    }
    
    /// 건물 상세 정보 조회
    func getBuildingDetail(buildingId: Int) async throws -> BuildingDetailResponseDTO {
        return try await request(.buildingDetail(buildingId: buildingId))
    }
    
    /// 건물 리뷰 목록 조회
    func getBuildingReviews(buildingId: Int) async throws -> BuildingReviewsResponseDTO {
        return try await request(.buildingReviews(buildingId: buildingId))
    }
    
    /// 리뷰 작성
    func createReview(
        buildingId: Int,
        rating: Int,
        content: String
    ) async throws -> CreateReviewResponseDTO {
        return try await request(.createReview(
            buildingId: buildingId,
            rating: rating,
            content: content
        ))
    }
    
    /// 찜한 건물 목록 조회
    func getSavedBuildings() async throws -> SavedBuildingsResponseDTO {
        return try await request(.savedBuildings)
    }
    
    /// 건물 찜하기
    func saveBuilding(buildingId: Int, memo: String?) async throws -> SaveBuildingResponseDTO {
        return try await request(.saveBuilding(buildingId: buildingId, memo: memo))
    }
    
    /// 찜한 건물 삭제
    func deleteSavedBuilding(saveId: Int) async throws -> DeleteSavedBuildingResponseDTO {
        return try await request(.deleteSavedBuilding(saveId: saveId))
    }
    
    /// 카테고리별 인프라 검색
    func getInfrastructureByCategory(
        category: InfraCategory,
        latitude: Double,
        longitude: Double,
        radiusMeters: Int
    ) async throws -> InfrastructureResponseDTO {
        return try await request(.infrastructureByCategory(
            category: category,
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters
        ))
    }
    
    /// 지역 통계 조회
    func getRegionStats(bjdCode: String) async throws -> RegionStatsResponseDTO {
        return try await request(.regionStats(bjdCode: bjdCode))
    }
    
    /// 환경 데이터 조회
    func getEnvironmentData(
        latitude: Double,
        longitude: Double
    ) async throws -> EnvironmentDataResponseDTO {
        return try await request(.environmentData(
            latitude: latitude,
            longitude: longitude
        ))
    }
}
