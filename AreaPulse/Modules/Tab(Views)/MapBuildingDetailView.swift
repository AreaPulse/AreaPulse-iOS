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
            
            Text(building.address)
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
            
            // 지도
            Map(initialPosition: .region(MKCoordinateRegion(
                center: building.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            ))) {
                Annotation(building.buildingName ?? "건물", coordinate: building.coordinate) {
                    Image(systemName: "building.2.fill")
                        .foregroundStyle(.red)
                }
            }
            .frame(height: 200)
            .clipShape(RoundedRectangle(cornerRadius: 12))
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
            Text("실거래가")
                .font(.headline)
                .fontWeight(.bold)
            
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
                        
                        Text("|\(recent.floor)층")
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
                    Label("리뷰 작성", systemImage: "square.and.pencil")
                        .font(.caption)
                }
            }
            
            if !viewModel.reviews.isEmpty {
                HStack {
                    RatingStarsView(rating: Int(viewModel.averageRating.rounded()))
                    
                    Text("\(viewModel.averageRating, specifier: "%.1f")")
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
                        Text("전체 리뷰 보기")
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                }
            } else {
                Text("아직 리뷰가 없습니다")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    // MARK: - Stats Section
    
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
    
    // MARK: - Environment Section
    
    private var environmentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
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
            
            ForEach(viewModel.nearbyInfrastructure.prefix(10)) { infra in
                HStack(spacing: 12) {
                    Image(systemName: infra.category.iconName)
                        .font(.title3)
                        .foregroundStyle(.blue)
                        .frame(width: 40)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(infra.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text(infra.category.displayName)
                            .font(.caption)
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

#Preview {
    NavigationStack {
        BuildingDetailView(
            buildingId: 1,
            navigationRouter: NavigationRouter()
        )
    }
}

#Preview("With Sample Data") {
    // 프리뷰용 샘플 빌딩
    let sampleBuilding = Building(
        id: 1,
        bjdCode: "1168010100",
        address: "서울특별시 강남구 역삼동 123-45",
        buildingName: "강남 센트럴 아파트",
        buildingType: .apartment,
        buildYear: 2018,
        totalUnits: 500,
        latitude: 37.5007,
        longitude: 127.0363
    )
    
    let sampleTransactions = [
        RealEstateTransaction(
            id: 1,
            buildingId: 1,
            transactionDate: Date().addingTimeInterval(-86400 * 30),
            price: 150000,
            areaSqm: 84.5,
            floor: 12
        ),
        RealEstateTransaction(
            id: 2,
            buildingId: 1,
            transactionDate: Date().addingTimeInterval(-86400 * 90),
            price: 145000,
            areaSqm: 84.5,
            floor: 8
        )
    ]
    
    let sampleReviews = [
        BuildingReview(
            id: 1,
            userId: 1,
            buildingId: 1,
            rating: 5,
            content: "조용하고 깨끗한 환경입니다. 교통도 편리하고 주변 상권이 잘 형성되어 있어요.",
            createdAt: Date().addingTimeInterval(-86400 * 10)
        ),
        BuildingReview(
            id: 2,
            userId: 2,
            buildingId: 1,
            rating: 4,
            content: "단지 내 시설이 좋고 관리도 잘 되는 편입니다. 다만 주차가 조금 불편해요.",
            createdAt: Date().addingTimeInterval(-86400 * 20)
        )
    ]
    
    NavigationStack {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 건물 기본 정보
                VStack(alignment: .leading, spacing: 12) {
                    Text(sampleBuilding.buildingType.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Capsule().fill(Color.blue.opacity(0.2)))
                    
                    Text(sampleBuilding.buildingName ?? "이름 없음")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(sampleBuilding.address)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 16) {
                        if let buildYear = sampleBuilding.buildYear {
                            Label("\(buildYear)년", systemImage: "calendar")
                                .font(.caption)
                        }
                        
                        if let totalUnits = sampleBuilding.totalUnits {
                            Label("\(totalUnits)세대", systemImage: "building.2")
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(.secondary)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemBackground))
                        .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
                )
                
                // 실거래가
                VStack(alignment: .leading, spacing: 12) {
                    Text("실거래가")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("최근 거래")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            
                            Spacer()
                            
                            Text(sampleTransactions[0].transactionDate, style: .date)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Text(sampleTransactions[0].formattedPrice)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.blue)
                        
                        HStack {
                            Text("전용면적: \(sampleTransactions[0].areaSqm, specifier: "%.2f")㎡")
                                .font(.caption)
                            
                            Text("| \(sampleTransactions[0].floor)층")
                                .font(.caption)
                        }
                        .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color(.secondarySystemBackground))
                    )
                }
                
                // 리뷰
                VStack(alignment: .leading, spacing: 12) {
                    Text("리뷰")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    HStack {
                        RatingStarsView(rating: 5)
                        Text("4.5")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                        Text("(2)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    ForEach(sampleReviews) { review in
                        ReviewRowView(review: review)
                    }
                }
            }
            .padding()
        }
        .navigationTitle(sampleBuilding.buildingName ?? "건물 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
}
