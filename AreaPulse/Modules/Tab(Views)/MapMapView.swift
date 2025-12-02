//
//  MapView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI
import MapKit

/// 메인 지도 화면
struct MapView: View {
    @State private var viewModel: MapViewModel
    let navigationRouter: NavigationRouter
    
    init(navigationRouter: NavigationRouter) {
        self.navigationRouter = navigationRouter
        _viewModel = State(initialValue: MapViewModel(navigationRouter: navigationRouter))
    }
    
    var body: some View {
        ZStack {
            mapLayer
            
            VStack(spacing: 12) {
                // 검색바
                mapSearchBar
                    .padding(.horizontal)
                    .padding(.top, 8)
                
                // 검색 결과 리스트
                if viewModel.showSearchResults {
                    searchResultsList
                        .padding(.horizontal)
                }
                
                // 인프라 필터 (건물 포함)
                if !viewModel.showSearchResults {
                    InfraCategoryFilterView(
                        selectedCategories: $viewModel.selectedInfraCategories,
                        showBuildings: $viewModel.showBuildings
                    )
                }
                
                Spacer()
                
                // 하단 정보 버튼
                if viewModel.selectedLocation != nil && !viewModel.showSearchResults {
                    nearbyInfoButton
                }
            }
            
            // 로딩 인디케이터
            if viewModel.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.2))
            }
        }
        .sheet(isPresented: $viewModel.isNearbyModalPresented) {
            NearbyInfoModalView(viewModel: viewModel)
        }
        .task {
            // 이미 로드했으면 스킵
            guard !viewModel.hasInitiallyLoaded else { return }
            
            // 위치 정보가 있을 때까지 대기 (최대 3초)
            var attempts = 0
            while viewModel.locationManager.userLocation == nil && attempts < 30 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1초 대기
                attempts += 1
            }
            
            // 사용자 위치 또는 폴백 위치로 초기 데이터 로드
            let initialLocation = viewModel.locationManager.userLocation ?? CLLocationCoordinate2D(
                latitude: 37.5665,
                longitude: 126.9780
            )
            
            await viewModel.handleMapTap(at: initialLocation)
            viewModel.hasInitiallyLoaded = true
        }
        .onChange(of: navigationRouter.destination) { _, _ in
            // NavigationRouter 변경 감지
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    // MARK: - Map Search Bar
    
    private var mapSearchBar: some View {
        HStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("장소, 주소 검색", text: $viewModel.searchText)
                    .autocorrectionDisabled()
                    .onSubmit {
                        Task {
                            await viewModel.performSearch()
                        }
                    }
                
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                        viewModel.searchResults = []
                        viewModel.showSearchResults = false
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
            )
        }
    }
    
    // MARK: - Search Results List
    
    private var searchResultsList: some View {
        ScrollView {
            VStack(spacing: 8) {
                if viewModel.searchResults.isEmpty {
                    Text("검색 결과가 없습니다")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    ForEach(viewModel.searchResults, id: \.self) { mapItem in
                        Button {
                            Task {
                                await viewModel.selectSearchResult(mapItem)
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundStyle(.blue)
                                    .font(.title3)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(mapItem.name ?? "이름 없음")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    
                                    if let address = mapItem.placemark.title {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .frame(maxHeight: 300)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, y: 2)
        )
    }
    
    // MARK: - Map Layer
    
    private var mapLayer: some View {
        MapReader { proxy in
            Map(position: .constant(.region(viewModel.region))) {
                // 사용자 위치 표시
                if let userLocation = viewModel.locationManager.userLocation {
                    Annotation("내 위치", coordinate: userLocation) {
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.3))
                                .frame(width: 32, height: 32)
                            
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 16, height: 16)
                                .overlay(
                                    Circle()
                                        .stroke(Color.white, lineWidth: 2)
                                )
                        }
                    }
                }
                
                // 선택된 위치 마커
                if let selectedLocation = viewModel.selectedLocation {
                    Annotation("선택 위치", coordinate: selectedLocation) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(.red)
                    }
                }
                
                // 건물 마커
                ForEach(viewModel.filteredBuildings) { building in
                    Annotation(building.buildingName ?? "건물", coordinate: building.coordinate) {
                        BuildingAnnotationView(
                            building: building,
                            isSelected: viewModel.selectedBuilding?.id == building.id
                        )
                    }
                    .annotationTitles(.hidden)
                }
                
                // 인프라 마커
                ForEach(viewModel.filteredInfrastructure) { infra in
                    Annotation(infra.name, coordinate: infra.coordinate) {
                        InfrastructureAnnotationView(infrastructure: infra)
                    }
                }
            }
            .onTapGesture { screenPosition in
                guard let coordinate = proxy.convert(screenPosition, from: .local) else { return }
                
                // 탭한 위치에서 가장 가까운 건물 찾기 (줌 레벨에 따라 threshold 조정)
                let threshold = viewModel.region.span.latitudeDelta * 0.05
                
                if let nearestBuilding = findNearestBuilding(to: coordinate, threshold: threshold) {
                    viewModel.selectBuilding(nearestBuilding)
                } else {
                    // 건물이 없으면 기존 로직
                    viewModel.selectedBuilding = nil
                    Task {
                        await viewModel.handleMapTap(at: coordinate)
                    }
                }
            }
        }
    }
    
    // MARK: - Find Nearest Building
    
    /// 탭한 좌표에서 가장 가까운 건물 찾기
    private func findNearestBuilding(to coordinate: CLLocationCoordinate2D, threshold: Double) -> Building? {
        var nearestBuilding: Building?
        var minDistance = threshold
        
        for building in viewModel.filteredBuildings {
            let distance = hypot(
                building.coordinate.latitude - coordinate.latitude,
                building.coordinate.longitude - coordinate.longitude
            )
            
            if distance < minDistance {
                minDistance = distance
                nearestBuilding = building
            }
        }
        
        return nearestBuilding
    }
    
    // MARK: - Nearby Info Button
    
    private var nearbyInfoButton: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.isNearbyModalPresented = true
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("주변 정보")
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        HStack(spacing: 12) {
                            if !viewModel.filteredBuildings.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "building.2.fill")
                                        .font(.caption2)
                                    Text("\(viewModel.filteredBuildings.count)개")
                                        .font(.caption)
                                }
                            }
                            
                            if !viewModel.filteredInfrastructure.isEmpty {
                                HStack(spacing: 4) {
                                    Image(systemName: "mappin.circle.fill")
                                        .font(.caption2)
                                    Text("\(viewModel.filteredInfrastructure.count)개")
                                        .font(.caption)
                                }
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.up")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color(.systemBackground))
                        .shadow(radius: 10)
                )
            }
            .buttonStyle(.plain)
            .padding(.horizontal)
            .padding(.bottom)
        }
    }
}

#Preview {
    NavigationStack {
        MapView(navigationRouter: NavigationRouter())
    }
}
