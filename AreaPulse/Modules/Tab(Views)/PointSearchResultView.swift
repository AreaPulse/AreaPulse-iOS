//
//  PointSearchResultView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI
import MapKit
import CoreLocation

/// 좌표 검색 결과 화면
struct PointSearchResultView: View {
    let latitude: Double
    let longitude: Double
    
    @State private var viewModel: PointSearchResultViewModel
    
    private var searchCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
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
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    // 환경 정보
                    if !viewModel.environmentData.isEmpty {
                        environmentSection
                    }
                    
                    // 주변 인프라
                    if !viewModel.nearbyInfrastructure.isEmpty {
                        infrastructureSection
                    }
                    
                    // 주변 건물 목록
                    if !viewModel.nearbyBuildings.isEmpty {
                        buildingsList
                    } else {
                        emptyState
                    }
                }
            }
            .padding()
        }
        .navigationTitle("위치 정보")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.loadAllData()
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
    
    // MARK: - Environment Section
    
    private var environmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("환경 정보")
                .font(.headline)
                .fontWeight(.bold)
            
            if let envData = viewModel.environmentData.first {
                HStack(spacing: 16) {
                    // 평균 소음
                    environmentCard(
                        title: "평균 소음",
                        value: String(format: "%.1f", envData.noiseAvg),
                        unit: "dB",
                        grade: envData.noiseGrade,
                        icon: "speaker.wave.2"
                    )
                    
                    // 최소 소음
                    environmentCard(
                        title: "최소 소음",
                        value: String(format: "%.1f", envData.noiseMin),
                        unit: "dB",
                        grade: noiseGrade(envData.noiseMin),
                        icon: "speaker.wave.1"
                    )
                    
                    // 최대 소음
                    environmentCard(
                        title: "최대 소음",
                        value: String(format: "%.1f", envData.noiseMax),
                        unit: "dB",
                        grade: noiseGrade(envData.noiseMax),
                        icon: "speaker.wave.3"
                    )
                }
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
    
    private func environmentCard(title: String, value: String, unit: String, grade: String, icon: String) -> some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(gradeColor(grade))
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.bold)
            
            Text(unit)
                .font(.caption2)
                .foregroundStyle(.secondary)
            
            Text(grade)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(gradeColor(grade))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func noiseGrade(_ db: Double?) -> String {
        guard let db = db else { return "정보없음" }
        switch db {
        case 0...40: return "조용함"
        case 41...55: return "보통"
        case 56...70: return "시끄러움"
        default: return "매우시끄러움"
        }
    }
    
    private func gradeColor(_ grade: String) -> Color {
        switch grade {
        case "좋음", "조용함": return .green
        case "보통": return .yellow
        case "나쁨", "시끄러움": return .orange
        default: return .red
        }
    }
    
    // MARK: - Infrastructure Section
    
    private var infrastructureSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주변 인프라")
                .font(.headline)
                .fontWeight(.bold)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 12) {
                infraCategoryCard(category: .subwayStation, icon: "tram.fill", color: .blue)
                infraCategoryCard(category: .school, icon: "graduationcap.fill", color: .green)
                infraCategoryCard(category: .hospital, icon: "cross.fill", color: .red)
                infraCategoryCard(category: .mart, icon: "cart.fill", color: .orange)
                infraCategoryCard(category: .park, icon: "leaf.fill", color: .mint)
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
    
    private func infraCategoryCard(category: InfraCategory, icon: String, color: Color) -> some View {
        let items = viewModel.infrastructureByCategory(category)
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Text(displayName(for: category))
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(items.count)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundStyle(color)
            }
            
            if let nearest = items.first {
                HStack {
                    Text(nearest.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    // 가장 가까운 인프라 거리 표시
                    let distance = calculateDistance(from: searchCoordinate, to: nearest.coordinate)
                    HStack(spacing: 2) {
                        Image(systemName: "figure.walk")
                            .font(.caption2)
                        Text(formatDistance(distance))
                            .font(.caption)
                    }
                    .foregroundStyle(color)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }
    
    private func displayName(for category: InfraCategory) -> String {
        switch category {
        case .subwayStation: return "지하철역"
        case .school: return "학교"
        case .hospital: return "병원"
        case .mart: return "마트"
        case .park: return "공원"
        case .busStop: return "버스정류장"
        case .bank: return "은행"
        case .publicOffice: return "관공서"
        case .cctv: return "CCTV"
        }
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
                    BuildingRowView(
                        building: building,
                        referenceCoordinate: searchCoordinate
                    )
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
    
    // MARK: - Helper Functions
    
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        } else {
            return String(format: "%.1fkm", meters / 1000)
        }
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
