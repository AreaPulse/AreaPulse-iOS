//
//  PointSearchResultViewModel.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation
import Observation

@Observable
class PointSearchResultViewModel {
    
    // MARK: - Properties
    
    var nearbyBuildings: [Building] = []
    var nearbyInfrastructure: [Infrastructure] = []
    var environmentData: [EnvironmentData] = []
    var regionStats: [RegionStats] = []
    var regionName: String = ""
    
    var isLoading: Bool = false
    var errorMessage: String?
    
    let latitude: Double
    let longitude: Double
    private let apiService: AreaPulseAPIService
    private let navigationRouter: NavigationRouter
    
    // 검색 반경 (미터)
    private let searchRadius: Int = 500
    
    // MARK: - Initialization
    
    init(
        latitude: Double,
        longitude: Double,
        apiService: AreaPulseAPIService = AreaPulseAPIService(),
        navigationRouter: NavigationRouter
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.apiService = apiService
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - Actions
    
    /// 모든 데이터 로드
    @MainActor
    func loadAllData() async {
        isLoading = true
        errorMessage = nil
        
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.searchNearbyBuildings() }
            group.addTask { await self.loadEnvironmentData() }
        }
        
        isLoading = false
    }
    
    /// 주변 건물 검색
    @MainActor
    func searchNearbyBuildings() async {
        do {
            let result = try await apiService.searchPoint(
                latitude: latitude,
                longitude: longitude,
                radiusMeters: searchRadius
            )
            
            nearbyBuildings = result.buildings
            nearbyInfrastructure = result.infrastructure
            
        } catch {
            errorMessage = error.localizedDescription
            print("Error searching nearby buildings: \(error)")
        }
    }
    
    /// 환경 데이터 로드
    @MainActor
    func loadEnvironmentData() async {
        do {
            let result = try await apiService.getEnvironmentData(
                latitude: latitude,
                longitude: longitude
            )
            environmentData = result.environmentData
        } catch {
            print("Error loading environment data: \(error)")
        }
    }
    
    /// 인프라 카테고리별 필터링
    func infrastructureByCategory(_ category: InfraCategory) -> [Infrastructure] {
        nearbyInfrastructure.filter { $0.category == category }
    }
    
    /// 건물 상세 화면으로 이동
    func navigateToBuildingDetail(buildingId: Int) {
        navigationRouter.push(to: .buildingDetail(buildingId: buildingId))
    }
}
