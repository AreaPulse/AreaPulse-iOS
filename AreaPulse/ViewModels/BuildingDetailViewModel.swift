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
    
    // MARK: - Nested Types
    
    enum SchoolFilter: String, CaseIterable {
        case all = "전체"
        case kindergarten = "유치원"
        case elementary = "초등학교"
        case middle = "중학교"
        case high = "고등학교"
        case special = "특수학교"
        
        var matchingKeywords: [String] {
            switch self {
            case .all:
                return []
            case .kindergarten:
                return ["유치원"]
            case .elementary:
                return ["초등학교", "초등"]
            case .middle:
                return ["중학교", "중학"]
            case .high:
                return ["고등학교", "고등"]
            case .special:
                return ["특수학교", "특수"]
            }
        }
        
        var schoolType: SchoolType? {
            switch self {
            case .all, .kindergarten:
                return nil
            case .elementary:
                return .elementary
            case .middle:
                return .middle
            case .high:
                return .high
            case .special:
                return .special
            }
        }
    }
    
    // MARK: - Properties
    
    var building: Building?
    var transactions: [RealEstateTransaction] = []
    var reviews: [BuildingReview] = []
    var nearbyInfrastructure: [Infrastructure] = []
    var regionStats: [RegionStats] = []
    var environmentData: [EnvironmentData] = []
    var realCctv: [CCTVLocation] = []
    var isLoading: Bool = false
    var errorMessage: String?
    var isSaved: Bool = false
    var saveId: Int?
    
    var selectedSchoolFilter: SchoolFilter = .all
    var showAllTransactions: Bool = false
    
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
            self.realCctv = result.realCctv
            
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
    
    /// 카테고리별 인프라 그룹화
    var infrastructureByCategory: [InfraCategory: [Infrastructure]] {
        Dictionary(grouping: nearbyInfrastructure) { $0.category }
    }
    
    /// 학교 목록 (필터 적용)
    var filteredSchools: [Infrastructure] {
        let schools = nearbyInfrastructure.filter { $0.category == .school }
        
        if selectedSchoolFilter == .all {
            return schools
        }
        
        // extraData에서 school_type 확인하거나 이름으로 매칭
        return schools.filter { infra in
            // 1. extraData에 school_type이 있는 경우
            if let extraData = infra.extraData,
               let schoolTypeStr = extraData["school_type"]?.value as? String,
               let schoolType = SchoolType(rawValue: schoolTypeStr) {
                // 선택된 필터의 SchoolType과 비교
                if let filterSchoolType = selectedSchoolFilter.schoolType {
                    return schoolType == filterSchoolType
                }
            }
            
            // 2. school_type이 없거나 유치원인 경우 이름으로 매칭
            return inferSchoolType(from: infra.name)
        }
    }
    
    /// 이름에서 학교 유형 유추
    private func inferSchoolType(from name: String) -> Bool {
        let keywords = selectedSchoolFilter.matchingKeywords
        return keywords.contains { keyword in
            name.contains(keyword)
        }
    }
    
    /// 지하철역 목록
    var subwayStations: [Infrastructure] {
        nearbyInfrastructure.filter { $0.category == .subwayStation }
    }
}
