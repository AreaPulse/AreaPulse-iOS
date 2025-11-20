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
    
    init(navigationRouter: NavigationRouter) {
        _viewModel = State(initialValue: MapViewModel(navigationRouter: navigationRouter))
    }
    
    var body: some View {
        ZStack {
            mapLayer
            
            VStack {
                // 인프라 필터
                InfraCategoryFilterView(selectedCategories: $viewModel.selectedInfraCategories)
                    .padding(.top)
                
                Spacer()
                
                // 하단 정보 패널
                if viewModel.selectedLocation != nil {
                    bottomInfoPanel
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
        .task {
            // 앱 시작 시 초기 위치(서울 중심)의 데이터 로드
            await viewModel.handleMapTap(at: CLLocationCoordinate2D(
                latitude: 37.5665,
                longitude: 126.9780
            ))
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
    
    // MARK: - Map Layer
    
    private var mapLayer: some View {
        MapReader { proxy in
            Map(position: .constant(.region(viewModel.region))) {
                // 선택된 위치 마커
                if let selectedLocation = viewModel.selectedLocation {
                    Annotation("선택 위치", coordinate: selectedLocation) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.title)
                            .foregroundStyle(.blue)
                    }
                }
                
                // 건물 마커
                ForEach(viewModel.nearbyBuildings) { building in
                    Annotation(building.buildingName ?? "건물", coordinate: building.coordinate) {
                        Button {
                            viewModel.selectBuilding(building)
                        } label: {
                            BuildingAnnotationView(
                                building: building,
                                isSelected: viewModel.selectedBuilding?.id == building.id
                            )
                        }
                    }
                }
                
                // 인프라 마커
                ForEach(viewModel.filteredInfrastructure) { infra in
                    Annotation(infra.name, coordinate: infra.coordinate) {
                        InfrastructureAnnotationView(infrastructure: infra)
                    }
                }
            }
            .onTapGesture { screenPosition in
                // MapReader를 사용하여 실제 탭한 위치의 좌표를 가져옴
                if let coordinate = proxy.convert(screenPosition, from: .local) {
                    Task {
                        await viewModel.handleMapTap(at: coordinate)
                    }
                }
            }
        }
    }
    
    // MARK: - Bottom Info Panel
    
    private var bottomInfoPanel: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 16) {
                    // 지역 통계
                    if !viewModel.regionStats.isEmpty {
                        statsSection
                    }
                    
                    // 환경 정보
                    if !viewModel.environmentData.isEmpty {
                        environmentSection
                    }
                    
                    // 주변 건물
                    if !viewModel.nearbyBuildings.isEmpty {
                        buildingsSection
                    }
                }
                .padding()
            }
        }
        .frame(maxHeight: UIScreen.main.bounds.height * 0.4)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(radius: 10)
        )
    }
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("지역 통계")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                ForEach(viewModel.regionStats) { stats in
                    StatsCardView(stats: stats)
                }
            }
        }
    }
    
    private var environmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(viewModel.environmentData) { data in
                EnvironmentDataCardView(data: data)
            }
        }
    }
    
    private var buildingsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주변 건물")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(viewModel.nearbyBuildings.prefix(5)) { building in
                Button {
                    viewModel.selectBuilding(building)
                } label: {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(building.buildingName ?? "이름 없음")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Text(building.address)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(building.buildingType.displayName)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(Color.blue.opacity(0.2)))
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        MapView(navigationRouter: NavigationRouter())
    }
}
