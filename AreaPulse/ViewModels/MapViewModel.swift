//
//  MapViewModel.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation
import MapKit
import Observation

@Observable
class MapViewModel {
    
    // MARK: - Properties
    
    var region: MKCoordinateRegion
    var selectedBuilding: Building?
    var nearbyBuildings: [Building] = []
    var nearbyInfrastructure: [Infrastructure] = []
    var regionStats: [RegionStats] = []
    var environmentData: [EnvironmentData] = []
    var selectedLocation: CLLocationCoordinate2D?
    var isLoading: Bool = false
    var errorMessage: String?
    
    /// 인프라 필터 (사용자가 선택한 카테고리)
    var selectedInfraCategories: Set<InfraCategory> = []
    
    private let apiService: AreaPulseAPIService
    private let navigationRouter: NavigationRouter
    
    // MARK: - Initialization
    
    init(
        apiService: AreaPulseAPIService = AreaPulseAPIService(),
        navigationRouter: NavigationRouter
    ) {
        self.apiService = apiService
        self.navigationRouter = navigationRouter
        
        // 기본 지역: 서울 중심
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
    
    // MARK: - Actions
    
    /// 지도에서 특정 지점 클릭
    @MainActor
    func handleMapTap(at coordinate: CLLocationCoordinate2D) async {
        selectedLocation = coordinate
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await apiService.searchPoint(
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                radiusMeters: 1000
            )
            
            self.nearbyBuildings = result.buildings
            self.nearbyInfrastructure = result.infrastructure
            
            // PointSearchResponseDTO에는 regionStats와 environmentData가 없으므로
            // 필요한 경우 별도 API 호출
            // 일단 빈 배열로 초기화
            self.regionStats = []
            self.environmentData = []
            
        } catch {
            errorMessage = error.localizedDescription
            print("Error searching point: \(error)")
        }
        
        isLoading = false
    }
    
    /// 건물 선택
    func selectBuilding(_ building: Building) {
        selectedBuilding = building
        navigationRouter.push(to: .buildingDetail(buildingId: building.id))
    }
    
    /// 인프라 카테고리 토글
    func toggleInfraCategory(_ category: InfraCategory) {
        if selectedInfraCategories.contains(category) {
            selectedInfraCategories.remove(category)
        } else {
            selectedInfraCategories.insert(category)
        }
    }
    
    /// 필터링된 인프라 목록
    var filteredInfrastructure: [Infrastructure] {
        if selectedInfraCategories.isEmpty {
            return nearbyInfrastructure
        }
        return nearbyInfrastructure.filter { selectedInfraCategories.contains($0.category) }
    }
    
    /// 지역을 특정 좌표로 이동
    func moveRegion(to coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
    }
}
