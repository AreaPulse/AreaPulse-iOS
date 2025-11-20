//
//  PointSearchResultView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI
import MapKit

/// 좌표 검색 결과 화면
struct PointSearchResultView: View {
    let latitude: Double
    let longitude: Double
    
    @State private var viewModel: PointSearchResultViewModel
    
    init(latitude: Double, longitude: Double, navigationRouter: NavigationRouter) {
        self.latitude = latitude
        self.longitude = longitude
        _viewModel = State(initialValue: PointSearchResultViewModel(
            latitude: latitude,
            longitude: longitude,
            navigationRouter: navigationRouter
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 지도 미리보기
                mapPreview
                
                // 좌표 정보
                coordinateInfo
                
                // 주변 건물 목록
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else if !viewModel.nearbyBuildings.isEmpty {
                    buildingsList
                } else {
                    emptyState
                }
            }
            .padding()
        }
        .navigationTitle("좌표 검색")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.searchNearbyBuildings()
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
    
    // MARK: - Map Preview
    
    private var mapPreview: some View {
        Map(position: .constant(.region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )))) {
            Marker("검색 위치", coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
                .tint(.red)
        }
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Coordinate Info
    
    private var coordinateInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("검색한 좌표")
                .font(.headline)
                .fontWeight(.bold)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("위도")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(latitude, specifier: "%.6f")")
                        .font(.body)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("경도")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(longitude, specifier: "%.6f")")
                        .font(.body)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
    }
    
    // MARK: - Buildings List
    
    private var buildingsList: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주변 건물 (\(viewModel.nearbyBuildings.count)개)")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(viewModel.nearbyBuildings) { building in
                Button {
                    viewModel.navigateToBuildingDetail(buildingId: building.id)
                } label: {
                    BuildingRowView(building: building)
                }
                .buttonStyle(.plain)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "building.2")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)
            
            Text("주변에 건물이 없습니다")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("다른 위치를 검색해보세요")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
}

/// 건물 한 줄 뷰
private struct BuildingRowView: View {
    let building: Building
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "building.2.fill")
                .font(.title2)
                .foregroundStyle(.blue)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                if let buildingName = building.buildingName {
                    Text(buildingName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                } else {
                    Text(building.address)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.primary)
                }
                
                Text(building.address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

#Preview {
    NavigationStack {
        PointSearchResultView(
            latitude: 37.5665,
            longitude: 126.9780,
            navigationRouter: NavigationRouter()
        )
    }
}
