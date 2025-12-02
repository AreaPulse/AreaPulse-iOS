//
//  ReviewWriteView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 리뷰 작성 화면
struct ReviewWriteView: View {
    @State private var viewModel: ReviewWriteViewModel
    @FocusState private var isContentFocused: Bool
    
    init(buildingId: Int, navigationRouter: NavigationRouter) {
        _viewModel = State(initialValue: ReviewWriteViewModel(
            buildingId: buildingId,
            navigationRouter: navigationRouter
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 별점 선택
                VStack(spacing: 12) {
                    Text("평점을 선택해주세요")
                        .font(.headline)
                    
                    Text(String(format: "%.1f", viewModel.rating))
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.yellow)
                    
                    RatingStarsSelectionView(rating: $viewModel.rating)
                }
                .padding()
                
                // 리뷰 내용
                VStack(alignment: .leading, spacing: 8) {
                    Text("리뷰 내용")
                        .font(.headline)
                    
                    TextEditor(text: $viewModel.content)
                        .frame(minHeight: 200)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .focused($isContentFocused)
                }
                .padding()
                
                // 제출 버튼
                Button {
                    Task {
                        await viewModel.submitReview()
                    }
                } label: {
                    if viewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                    } else {
                        Text("리뷰 작성 완료")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(viewModel.isValidInput ? Color.blue : Color.gray)
                .foregroundStyle(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .disabled(!viewModel.isValidInput || viewModel.isLoading)
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("리뷰 작성")
        .navigationBarTitleDisplayMode(.inline)
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
}

#Preview {
    NavigationStack {
        ReviewWriteView(
            buildingId: 1,
            navigationRouter: NavigationRouter()
        )
    }
}
