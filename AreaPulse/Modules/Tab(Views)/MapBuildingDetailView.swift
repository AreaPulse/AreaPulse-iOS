//
//  BuildingDetailView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI
import MapKit

/// 건물 상세 정보 화면
struct BuildingDetailView: View {
    @State private var viewModel: BuildingDetailViewModel
    
    init(buildingId: Int, navigationRouter: NavigationRouter) {
        _viewModel = State(initialValue: BuildingDetailViewModel(
            buildingId: buildingId,
            navigationRouter: navigationRouter
        ))
    }
    
    var body: some View {
        ScrollView {
            if let building = viewModel.building {
                VStack(spacing: 20) {
                    // 건물 기본 정보
                    buildingInfoSection(building: building)
                    
                    // 실거래가
                    if !viewModel.transactions.isEmpty {
                        transactionsSection
                    }
                    
                    // 리뷰
                    reviewsSection
                    
                    // 지하철역 정보
                    if !viewModel.subwayStations.isEmpty {
                        subwaySection
                    }
                    
                    // 지역 통계
                    if !viewModel.regionStats.isEmpty {
                        statsSection
                    }
                    
                    // 환경 정보
                    if !viewModel.environmentData.isEmpty {
                        environmentSection
                    }
                    
                    // 주변 인프라
                    if !viewModel.nearbyInfrastructure.isEmpty {
                        nearbyInfraSection
                    }
                }
                .padding()
            } else if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text("건물 정보를 불러올 수 없습니다")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle(viewModel.building?.buildingName ?? "건물 정보")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    Task {
                        await viewModel.toggleSave()
                    }
                } label: {
                    Image(systemName: viewModel.isSaved ? "heart.fill" : "heart")
                        .foregroundStyle(viewModel.isSaved ? .red : .gray)
                }
            }
        }
        .task {
            await viewModel.loadBuildingDetail()
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
    
    // MARK: - Building Info Section
    
    private func buildingInfoSection(building: Building) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(building.buildingType.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.blue.opacity(0.2)))
                
                Spacer()
            }
            
            Text(building.buildingName ?? "이름 없음")
                .font(.title2)
                .fontWeight(.bold)
            
            Text(building.address ?? "주소 정보 없음")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            if let buildYear = building.buildYear {
                HStack(spacing: 16) {
                    Label("\(buildYear)년", systemImage: "calendar")
                        .font(.caption)
                    
                    if let totalUnits = building.totalUnits {
                        Label("\(totalUnits)세대", systemImage: "building.2")
                            .font(.caption)
                    }
                }
                .foregroundStyle(.secondary)
            }
            
            // 지도 (CCTV 포함)
            Map(initialPosition: .region(MKCoordinateRegion(
                center: building.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))) {
                // 건물 위치
                Annotation(building.buildingName ?? "건물", coordinate: building.coordinate) {
                    Image(systemName: "building.2.fill")
                        .foregroundStyle(.red)
                        .font(.title2)
                }
                
                // CCTV 위치
                ForEach(Array(viewModel.realCctv.enumerated()), id: \.offset) { index, cctv in
                    Annotation("CCTV", coordinate: CLLocationCoordinate2D(latitude: cctv.lat, longitude: cctv.lon)) {
                        Image(systemName: "video.fill")
                            .foregroundStyle(.blue)
                            .font(.caption)
                    }
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // CCTV 개수 표시
            if !viewModel.realCctv.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "video.fill")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Text("주변 CCTV \(viewModel.realCctv.count)개")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
    }
    
    // MARK: - Transactions Section
    
    private var transactionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("실거래가")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                if viewModel.transactions.count > 1 {
                    Button {
                        viewModel.showAllTransactions = true
                    } label: {
                        HStack(spacing: 4) {
                            Text("더보기")
                            Image(systemName: "chevron.right")
                        }
                        .font(.caption)
                        .foregroundStyle(.blue)
                    }
                }
            }
            
            if let recent = viewModel.recentTransaction {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("최근 거래")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                        
                        Text(recent.transactionDate, style: .date)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Text(recent.formattedPrice)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.blue)
                    
                    HStack {
                        Text("전용면적: \(recent.areaSqm, specifier: "%.2f")㎡")
                            .font(.caption)
                        
                        Text("| \(Int(recent.floor))층")
                            .font(.caption)
                    }
                    .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            
            if viewModel.transactions.count > 1 {
                Text("총 \(viewModel.transactions.count)건의 거래")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .sheet(isPresented: $viewModel.showAllTransactions) {
            AllTransactionsView(transactions: viewModel.transactions)
        }
    }
    
    // MARK: - Reviews Section
    
    private var reviewsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("리뷰")
                    .font(.headline)
                    .fontWeight(.bold)
                
                Spacer()
                
                Button {
                    viewModel.navigateToReviewWrite()
                } label: {
                    Text("작성하기")
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            }
            
            if viewModel.reviews.isEmpty {
                Text("아직 리뷰가 없습니다")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                HStack {
                    RatingStarsView(rating: viewModel.averageRating)
                    Text(String(format: "%.1f", viewModel.averageRating))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("(\(viewModel.reviews.count))")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                ForEach(viewModel.reviews.prefix(3)) { review in
                    ReviewRowView(review: review)
                }
                
                if viewModel.reviews.count > 3 {
                    Button {
                        viewModel.navigateToReviewList()
                    } label: {
                        Text("리뷰 전체보기 (\(viewModel.reviews.count))")
                            .font(.caption)
                            .foregroundStyle(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)
                    }
                }
            }
        }
    }
    
    // MARK: - Subway Section
    
    private var subwaySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주변 지하철")
                .font(.headline)
                .fontWeight(.bold)
            
            VStack(spacing: 8) {
                ForEach(viewModel.subwayStations) { station in
                    HStack(spacing: 12) {
                        // 노선 뱃지
                        if let line = station.extraData?["line"]?.value as? Int {
                            Text("\(line)호선")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    Capsule()
                                        .fill(getSubwayLineColor(for: line))
                                )
                        }
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(station.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            HStack(spacing: 8) {
                                // 승객 수
                                if let passengerNum = station.passengerNum {
                                    HStack(spacing: 2) {
                                        Image(systemName: "person.fill")
                                            .font(.caption2)
                                        Text("\(passengerNum)명")
                                            .font(.caption2)
                                    }
                                }
                                
                                // 혼잡도
                                if let complexity = station.complexityRating {
                                    HStack(spacing: 2) {
                                        Image(systemName: "chart.bar.fill")
                                            .font(.caption2)
                                        Text("혼잡도 \(complexity)/10")
                                            .font(.caption2)
                                    }
                                    .foregroundStyle(getComplexityColor(for: complexity))
                                }
                            }
                            .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
            }
        }
    }
    
    // MARK: - Stats Section
    
    private var statsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("지역 통계")
                .font(.headline)
                .fontWeight(.bold)
            
            if let stats = viewModel.regionStats.first {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    StatsCardView(stats: stats, statsType: .crime)
                    StatsCardView(stats: stats, statsType: .cctv)
                    StatsCardView(stats: stats, statsType: .dangerousRating)
                    StatsCardView(stats: stats, statsType: .cctvSecurityRating)
                }
            }
        }
    }
    
    // MARK: - Environment Section
    
    private var environmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("환경 정보")
                .font(.headline)
                .fontWeight(.bold)
            
            ForEach(viewModel.environmentData) { data in
                EnvironmentDataCardView(data: data)
            }
        }
    }
    
    // MARK: - Nearby Infrastructure Section
    
    private var nearbyInfraSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("주변 인프라")
                .font(.headline)
                .fontWeight(.bold)
            
            // 학교 섹션 (필터 포함)
            if !viewModel.filteredSchools.isEmpty || viewModel.nearbyInfrastructure.contains(where: { $0.category == .school }) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: InfraCategory.school.iconName)
                            .foregroundStyle(.blue)
                        Text("학교")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        
                        Spacer()
                    }
                    
                    // 학교 필터
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(BuildingDetailViewModel.SchoolFilter.allCases, id: \.self) { filter in
                                Button {
                                    viewModel.selectedSchoolFilter = filter
                                } label: {
                                    Text(filter.rawValue)
                                        .font(.caption)
                                        .fontWeight(viewModel.selectedSchoolFilter == filter ? .semibold : .regular)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            Capsule()
                                                .fill(viewModel.selectedSchoolFilter == filter ? Color.blue : Color(.systemGray5))
                                        )
                                        .foregroundStyle(viewModel.selectedSchoolFilter == filter ? .white : .primary)
                                }
                            }
                        }
                    }
                    
                    if viewModel.filteredSchools.isEmpty {
                        Text("해당하는 학교가 없습니다")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.vertical, 8)
                    } else {
                        ForEach(viewModel.filteredSchools) { school in
                            InfrastructureDetailRow(infrastructure: school)
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(.secondarySystemBackground))
                )
            }
            
            // 기타 인프라 (카테고리별)
            ForEach(Array(viewModel.infrastructureByCategory.keys.filter { $0 != .school && $0 != .subwayStation }.sorted(by: { $0.displayName < $1.displayName })), id: \.self) { category in
                if let items = viewModel.infrastructureByCategory[category], !items.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: category.iconName)
                                .foregroundStyle(.blue)
                            Text(category.displayName)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text("\(items.count)개")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        ForEach(items.prefix(5)) { infra in
                            InfrastructureDetailRow(infrastructure: infra)
                        }
                        
                        if items.count > 5 {
                            Text("외 \(items.count - 5)개")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    /// 호선별 색상 반환
    private func getSubwayLineColor(for line: Int) -> Color {
        switch line {
        case 1: return Color(red: 0.0, green: 0.33, blue: 0.65) // 진남색
        case 2: return Color(red: 0.13, green: 0.64, blue: 0.30) // 녹색
        case 3: return Color(red: 0.93, green: 0.46, blue: 0.0) // 주황색
        case 4: return Color(red: 0.0, green: 0.66, blue: 0.85) // 하늘색
        case 5: return Color(red: 0.56, green: 0.27, blue: 0.68) // 보라색
        case 6: return Color(red: 0.62, green: 0.36, blue: 0.22) // 갈색
        case 7: return Color(red: 0.40, green: 0.47, blue: 0.21) // 올리브색
        case 8: return Color(red: 0.89, green: 0.11, blue: 0.46) // 분홍색
        case 9: return Color(red: 0.73, green: 0.60, blue: 0.42) // 금색
        default: return .gray
        }
    }
    
    /// 혼잡도에 따른 색상 반환
    private func getComplexityColor(for rating: Int) -> Color {
        switch rating {
        case 1...3: return .green
        case 4...6: return .yellow
        case 7...8: return .orange
        case 9...10: return .red
        default: return .gray
        }
    }
}

// MARK: - All Transactions View

struct AllTransactionsView: View {
    let transactions: [RealEstateTransaction]
    @Environment(\.dismiss) private var dismiss
    
    var sortedTransactions: [RealEstateTransaction] {
        transactions.sorted { $0.transactionDate > $1.transactionDate }
    }
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(sortedTransactions) { transaction in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text(transaction.formattedPrice)
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundStyle(.blue)
                            
                            Spacer()
                            
                            Text(transaction.transactionDate, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        HStack(spacing: 16) {
                            HStack(spacing: 4) {
                                Image(systemName: "square.grid.3x3")
                                    .font(.caption2)
                                Text("\(transaction.areaSqm, specifier: "%.2f")㎡")
                                    .font(.caption)
                            }
                            
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.up.to.line")
                                    .font(.caption2)
                                Text("\(Int(transaction.floor))층")
                                    .font(.caption)
                            }
                            
                            // 평당 가격 계산
                            HStack(spacing: 4) {
                                Image(systemName: "wonsign.circle")
                                    .font(.caption2)
                                Text("\(Int(transaction.pricePerPyeong))만원/평")
                                    .font(.caption)
                            }
                        }
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("전체 거래 내역")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Infrastructure Detail Row

struct InfrastructureDetailRow: View {
    let infrastructure: Infrastructure
    
    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                Text(infrastructure.name)
                    .font(.caption)
                    .fontWeight(.medium)
                
                if let address = infrastructure.address {
                    Text(address)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

// MARK: - RealEstateTransaction Extension

extension RealEstateTransaction {
    /// 평당 가격 계산 (1평 = 3.3058㎡)
    var pricePerPyeong: Double {
        let pyeong = areaSqm / 3.3058
        return Double(price) / pyeong
    }
}

#Preview {
    NavigationStack {
        BuildingDetailView(
            buildingId: 1,
            navigationRouter: NavigationRouter()
        )
    }
}
