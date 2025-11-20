//
//  ReviewRowView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 리뷰 한 줄 뷰
struct ReviewRowView: View {
    let review: BuildingReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                RatingStarsView(rating: review.rating)
                
                Spacer()
                
                Text(review.createdAt, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text(review.content)
                .font(.body)
                .lineLimit(nil)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.secondarySystemBackground))
        )
    }
}
