//
//  RatingStarsView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 별점 표시 뷰
struct RatingStarsView: View {
    let rating: Double
    let maxRating: Int = 5
    
    // Int를 받는 초기화
    init(rating: Int) {
        self.rating = Double(rating)
    }
    
    // Double을 받는 초기화
    init(rating: Double) {
        self.rating = rating
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: starName(for: index))
                    .font(.caption)
                    .foregroundStyle(starColor(for: index))
            }
        }
    }
    
    private func starName(for index: Int) -> String {
        let difference = rating - Double(index - 1)
        
        if difference >= 1.0 {
            return "star.fill"
        } else if difference > 0.0 && difference < 1.0 {
            return "star.leadinghalf.fill"
        } else {
            return "star"
        }
    }
    
    private func starColor(for index: Int) -> Color {
        return rating >= Double(index - 1) ? .yellow : .gray
    }
}

/// 별점 선택 뷰 (탭 가능)
struct RatingStarsSelectionView: View {
    @Binding var rating: Int
    let maxRating: Int = 5
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...maxRating, id: \.self) { index in
                Button {
                    rating = index
                } label: {
                    Image(systemName: index <= rating ? "star.fill" : "star")
                        .font(.title2)
                        .foregroundStyle(index <= rating ? .yellow : .gray)
                }
            }
        }
    }
}

#Preview("Rating Stars") {
    VStack(spacing: 20) {
        RatingStarsView(rating: 5)
        RatingStarsView(rating: 4)
        RatingStarsView(rating: 3)
        RatingStarsView(rating: 2)
        RatingStarsView(rating: 1)
    }
    .padding()
}

#Preview("Rating Stars Selection") {
    @Previewable @State var rating = 3
    
    VStack(spacing: 20) {
        Text("선택된 별점: \(rating)")
            .font(.headline)
        
        RatingStarsSelectionView(rating: $rating)
    }
    .padding()
}
