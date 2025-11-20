//
//  InfraCategoryFilterView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 인프라 카테고리 필터 버튼들
struct InfraCategoryFilterView: View {
    @Binding var selectedCategories: Set<InfraCategory>
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(InfraCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        category: category,
                        isSelected: selectedCategories.contains(category),
                        action: {
                            toggleCategory(category)
                        }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func toggleCategory(_ category: InfraCategory) {
        if selectedCategories.contains(category) {
            selectedCategories.remove(category)
        } else {
            selectedCategories.insert(category)
        }
    }
}

private struct CategoryChip: View {
    let category: InfraCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.iconName)
                    .font(.caption)
                Text(category.displayName)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue : Color.gray.opacity(0.2))
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
    }
}

#Preview {
    @Previewable @State var selectedCategories: Set<InfraCategory> = [.school, .park]
    
    VStack(spacing: 20) {
        InfraCategoryFilterView(selectedCategories: $selectedCategories)
        
        Text("선택된 카테고리: \(selectedCategories.count)개")
            .font(.caption)
    }
}
