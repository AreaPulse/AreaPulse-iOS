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
    
    // MARK: - Nested Types
    
    enum NearbyTab {
        case infrastructure
        case buildings
    }
    
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
    
    var searchText: String = ""
    var isNearbyModalPresented: Bool = false
    var selectedTab: NearbyTab = .infrastructure
    var searchResults: [MKMapItem] = []
    var showSearchResults: Bool = false
    
    /// 인프라 필터 (사용자가 선택한 카테고리) - 기본값: 전체 선택
    var selectedInfraCategories: Set<InfraCategory> = Set(InfraCategory.allCases)
    
    /// 건물 표시 여부 - 기본값: 표시
    var showBuildings: Bool = true
    
    /// 선택된 인프라 카테고리 (상세 목록 표시용)
    var selectedInfraCategory: InfraCategory?
    
    /// 건물 목록 표시 여부
    var showBuildingList: Bool = false
    
    /// 위치 관리자
    var locationManager = LocationManager()
    
    /// 초기 로드 완료 여부
    var hasInitiallyLoaded: Bool = false
    
    private let apiService: AreaPulseAPIService
    private let navigationRouter: NavigationRouter
    
    // MARK: - Initialization
    
    init(
        apiService: AreaPulseAPIService = AreaPulseAPIService(),
        navigationRouter: NavigationRouter
    ) {
        self.apiService = apiService
        self.navigationRouter = navigationRouter
        
        // 기본 지역: 서울 중심 (더 가까운 확대)
        self.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        // 위치 권한 요청
        locationManager.requestLocation()
    }
    
    // MARK: - Actions
    
    /// 지도에서 특정 지점 클릭
    @MainActor
    func handleMapTap(at coordinate: CLLocationCoordinate2D) async {
        selectedLocation = coordinate
        region.center = coordinate
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
            self.regionStats = result.regionStats ?? []
            self.environmentData = result.environmentData ?? []
            
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
            return []
        }
        return nearbyInfrastructure.filter { selectedInfraCategories.contains($0.category) }
    }
    
    /// 필터링된 건물 목록
    var filteredBuildings: [Building] {
        if showBuildings {
            return nearbyBuildings
        }
        return []
    }
    
    /// 지역을 특정 좌표로 이동
    func moveRegion(to coordinate: CLLocationCoordinate2D) {
        region = MKCoordinateRegion(
            center: coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    }
    
    /// 위치 상세 정보 화면으로 이동
    func navigateToPointSearchResult() {
        guard let location = selectedLocation else {
            print("❌ selectedLocation is nil")
            return
        }
        print("✅ Navigating to point search result: \(location.latitude), \(location.longitude)")
        navigationRouter.push(to: .pointSearchResult(
            latitude: location.latitude,
            longitude: location.longitude
        ))
    }
    
    /// 장소 검색
    @MainActor
    func performSearch() async {
        let text = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else {
            searchResults = []
            showSearchResults = false
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = text
        request.region = region
        
        do {
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            
            searchResults = response.mapItems
            showSearchResults = true
        } catch {
            print("Search error: \(error)")
            searchResults = []
            showSearchResults = false
        }
    }
    
    /// 검색 결과 선택
    @MainActor
    func selectSearchResult(_ mapItem: MKMapItem) async {
        let coordinate = mapItem.placemark.coordinate
        
        // 지도 이동
        moveRegion(to: coordinate)
        
        // 해당 위치 검색
        await handleMapTap(at: coordinate)
        
        // 검색 결과 닫기
        searchText = ""
        searchResults = []
        showSearchResults = false
    }
}
