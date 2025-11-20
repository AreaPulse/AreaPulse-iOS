//
//  ReviewWriteViewModel.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation
import Observation

@Observable
class ReviewWriteViewModel {
    
    // MARK: - Properties
    
    var rating: Int = 5
    var content: String = ""
    var isLoading: Bool = false
    var errorMessage: String?
    var isSubmitSuccessful: Bool = false
    
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
                isSubmitSuccessful = true
                // 리뷰 작성 성공 후 이전 화면으로 돌아가기
                navigationRouter.pop()
            } else {
                errorMessage = response.message
            }
            
        } catch {
            errorMessage = error.localizedDescription
            print("Error submitting review: \(error)")
        }
        
        isLoading = false
    }
}
