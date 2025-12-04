// ReviewWriteViewModel.swift
import Foundation
import Observation

@Observable
class ReviewWriteViewModel {
    
    // MARK: - Properties
    
    var rating: Int = 5
    var content: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    
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
    
    // MARK: - Validation
    
    var isValidInput: Bool {
        !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Actions
    
    /// 리뷰 제출
    @MainActor
    func submitReview() async {
        guard isValidInput else {
            errorMessage = "리뷰 내용을 입력해주세요"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.createReview(
                buildingId: buildingId,
                rating: rating,
                content: content
            )
            
            if response.success {
                navigationRouter.pop()
            } else {
                errorMessage = response.message
            }
            
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
