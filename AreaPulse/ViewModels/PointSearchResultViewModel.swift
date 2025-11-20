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
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let latitude: Double
    private let longitude: Double
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
    
    /// 주변 건물 검색
    @MainActor
    func searchNearbyBuildings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await apiService.searchPoint(
                latitude: latitude,
                longitude: longitude,
                radiusMeters: searchRadius
            )
            
            nearbyBuildings = result.buildings
            
        } catch {
            errorMessage = error.localizedDescription
            print("Error searching nearby buildings: \(error)")
        }
        
        isLoading = false
    }
    
    /// 건물 상세 화면으로 이동
    func navigateToBuildingDetail(buildingId: Int) {
        navigationRouter.push(to: .buildingDetail(buildingId: buildingId))
    }
}
