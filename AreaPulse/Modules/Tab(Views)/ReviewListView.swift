//
//  ReviewListView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 리뷰 목록 화면
struct ReviewListView: View {
    let buildingId: Int
    @State private var reviews: [BuildingReview] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    
    private let apiService = AreaPulseAPIService()
    
    var body: some View {
        Group {
            if isLoading {
                ProgressView()
            } else if reviews.isEmpty {
                Text("리뷰가 없습니다")
                    .foregroundStyle(.secondary)
            } else {
                List(reviews) { review in
                    ReviewRowView(review: review)
                        .listRowSeparator(.hidden)
                }
                .listStyle(.plain)
            }
        }
        .navigationTitle("전체 리뷰")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadReviews()
        }
        .alert("오류", isPresented: .constant(errorMessage != nil)) {
            Button("확인") {
                errorMessage = nil
            }
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func loadReviews() async {
        isLoading = true
        
        do {
            let response = try await apiService.getBuildingReviews(buildingId: buildingId)
            reviews = response.reviews
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}

#Preview {
    NavigationStack {
        ReviewListView(buildingId: 1)
    }
}

#Preview("With Sample Data") {
    // 프리뷰용 샘플 데이터
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
        ),
        BuildingReview(
            id: 3,
            userId: 3,
            buildingId: 1,
            rating: 5,
            content: "학군이 좋아서 만족스럽습니다. 주변에 공원도 가까워 아이 키우기 좋아요.",
            createdAt: Date().addingTimeInterval(-86400 * 30)
        )
    ]
    
    NavigationStack {
        List(sampleReviews) { review in
            ReviewRowView(review: review)
                .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
        .navigationTitle("전체 리뷰")
        .navigationBarTitleDisplayMode(.inline)
    }
}
