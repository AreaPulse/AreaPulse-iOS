//
//  InfraCategoryFilterView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 지도 필터 카테고리 (인프라 + 건물)
enum MapFilterCategory: Hashable, CaseIterable {
    case building
    case infra(InfraCategory)
    
    static var allCases: [MapFilterCategory] {
        [.building] + InfraCategory.allCases.map { .infra($0) }
    }
    
    var displayName: String {
        switch self {
        case .building:
            return "건물"
        case .infra(let category):
            return category.displayName
        }
    }
    
    var iconName: String {
        switch self {
        case .building:
            return "building.2.fill"
        case .infra(let category):
            return category.iconName
        }
    }
}

/// 인프라 카테고리 필터 버튼들 (건물 포함)
struct InfraCategoryFilterView: View {
    @Binding var selectedCategories: Set<InfraCategory>
    @Binding var showBuildings: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // 건물 필터
                CategoryChip(
                    displayName: "건물",
                    iconName: "building.2.fill",
                    isSelected: showBuildings,
                    action: {
                        showBuildings.toggle()
                    }
                )
                
                // 인프라 필터
                ForEach(InfraCategory.allCases, id: \.self) { category in
                    CategoryChip(
                        displayName: category.displayName,
                        iconName: category.iconName,
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
    let displayName: String
    let iconName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.caption)
                Text(displayName)
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
    @Previewable @State var selectedCategories: Set<InfraCategory> = Set(InfraCategory.allCases)
    @Previewable @State var showBuildings: Bool = true
    
    VStack(spacing: 20) {
        InfraCategoryFilterView(
            selectedCategories: $selectedCategories,
            showBuildings: $showBuildings
        )
        
        Text("건물: \(showBuildings ? "표시" : "숨김")")
            .font(.caption)
        Text("선택된 인프라: \(selectedCategories.count)개")
            .font(.caption)
    }
}
