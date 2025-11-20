//
//  BuildingDetailViewModel.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation
import Observation

@Observable
class BuildingDetailViewModel {
    
    // MARK: - Properties
    
    var building: Building?
    var transactions: [RealEstateTransaction] = []
    var reviews: [BuildingReview] = []
    var nearbyInfrastructure: [Infrastructure] = []
    var regionStats: [RegionStats] = []
    var environmentData: [EnvironmentData] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var isSaved: Bool = false
    var saveId: Int?
    
    private let buildingId: Int
    private let apiService: AreaPulseAPIService
    private let navigationRouter: NavigationRouter
    
    // MARK: - Initialization
    
    init(
        buildingId: Int,
        apiService: AreaPulseAPIService = AreaPulseAPIService(),
        navigationRouter: NavigationRouter
    ) {
        self.buildingId = buildingId
        self.apiService = apiService
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - Actions
    
    /// 건물 상세 정보 로드
    @MainActor
    func loadBuildingDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await apiService.getBuildingDetail(buildingId: buildingId)
            
            self.building = result.building
            self.transactions = result.transactions
            self.reviews = result.reviews
            self.nearbyInfrastructure = result.nearbyInfrastructure
            self.regionStats = result.regionStats
            self.environmentData = result.environmentData
            
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading building detail: \(error)")
        }
        
        isLoading = false
    }
    
    /// 리뷰 작성 화면으로 이동
    func navigateToReviewWrite() {
        navigationRouter.push(to: .reviewWrite(buildingId: buildingId))
    }
    
    /// 리뷰 목록 화면으로 이동
    func navigateToReviewList() {
        navigationRouter.push(to: .reviewList(buildingId: buildingId))
    }
    
    /// 건물 찜하기/해제
    @MainActor
    func toggleSave() async {
        do {
            if isSaved, let saveId = saveId {
                let response = try await apiService.deleteSavedBuilding(saveId: saveId)
                if response.success {
                    isSaved = false
                    self.saveId = nil
                }
            } else {
                let response = try await apiService.saveBuilding(buildingId: buildingId)
                if response.success {
                    isSaved = true
                    self.saveId = response.saveId
                }
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error toggling save: \(error)")
        }
    }
    
    /// 평균 평점 계산
    var averageRating: Double {
        guard !reviews.isEmpty else { return 0 }
        let sum = reviews.reduce(0) { $0 + $1.rating }
        return Double(sum) / Double(reviews.count)
    }
    
    /// 최근 실거래가
    var recentTransaction: RealEstateTransaction? {
        transactions.sorted { $0.transactionDate > $1.transactionDate }.first
    }
}
