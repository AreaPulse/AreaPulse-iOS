//
//  AreaPulseAPIService.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

/// AreaPulse 전용 API 서비스 (Moya 기반)
/// 이 클래스는 MoyaAPIService를 래핑하여 더 편리한 인터페이스를 제공합니다.
class AreaPulseAPIService {
    
    // MARK: - Properties
    
    static let shared = AreaPulseAPIService()
    
    private let moyaService: MoyaAPIService
    
    // MARK: - Initialization
    
    init(moyaService: MoyaAPIService = .shared) {
        self.moyaService = moyaService
    }
    
    // MARK: - 핀포인트 검색
    
    /// 지도 상의 특정 지점 클릭 시 주변 정보 검색
    func searchPoint(
        latitude: Double,
        longitude: Double,
        radiusMeters: Int = 1000
    ) async throws -> PointSearchResponseDTO {
        return try await moyaService.searchPoint(
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters
        )
    }
    
    // MARK: - 건물 상세 정보
    
    /// 특정 건물의 상세 정보 조회
    func getBuildingDetail(buildingId: Int) async throws -> BuildingDetailResponseDTO {
        return try await moyaService.getBuildingDetail(buildingId: buildingId)
    }
    
    /// 건물의 리뷰 목록 조회
    func getBuildingReviews(buildingId: Int) async throws -> BuildingReviewsResponseDTO {
        return try await moyaService.getBuildingReviews(buildingId: buildingId)
    }
    
    // MARK: - 리뷰
    
    /// 건물 리뷰 작성
    func createReview(
        buildingId: Int,
        rating: Int,
        content: String
    ) async throws -> CreateReviewResponseDTO {
        return try await moyaService.createReview(
            buildingId: buildingId,
            rating: rating,
            content: content
        )
    }
    
    // MARK: - 찜하기
    
    /// 사용자의 찜한 건물 목록 조회
    func getSavedBuildings() async throws -> SavedBuildingsResponseDTO {
        return try await moyaService.getSavedBuildings()
    }
    
    /// 건물 찜하기
    func saveBuilding(buildingId: Int, memo: String? = nil) async throws -> SaveBuildingResponseDTO {
        return try await moyaService.saveBuilding(buildingId: buildingId, memo: memo)
    }
    
    /// 찜한 건물 삭제
    func deleteSavedBuilding(saveId: Int) async throws -> AreaPulse.DeleteSavedBuildingResponseDTO {
        return try await moyaService.deleteSavedBuilding(saveId: saveId)
    }
    
    // MARK: - 인프라
    
    /// 카테고리별 인프라 검색
    func getInfrastructureByCategory(
        category: InfraCategory,
        latitude: Double,
        longitude: Double,
        radiusMeters: Int = 1000
    ) async throws -> InfrastructureResponseDTO {
        return try await moyaService.getInfrastructureByCategory(
            category: category,
            latitude: latitude,
            longitude: longitude,
            radiusMeters: radiusMeters
        )
    }
    
    // MARK: - 지역 통계
    
    /// 지역 통계 조회
    func getRegionStats(bjdCode: String) async throws -> RegionStatsResponseDTO {
        return try await moyaService.getRegionStats(bjdCode: bjdCode)
    }
    
    // MARK: - 환경 데이터
    
    /// 환경 데이터 조회 (대기질, 소음)
    func getEnvironmentData(
        latitude: Double,
        longitude: Double
    ) async throws -> EnvironmentDataResponseDTO {
        return try await moyaService.getEnvironmentData(
            latitude: latitude,
            longitude: longitude
        )
    }
}

