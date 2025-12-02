//
//  BuildingTypeFilterView.swift
//  AreaPulse
//

import SwiftUI

/// 지도 필터에서 사용할 건물 타입 (실제 데이터에 있는 것만)
extension BuildingType {
    static let mapFilterTypes: [BuildingType] = [.apartment, .rowHouse]
}

/// 건물 타입 필터 뷰 (건물 표시가 켜져있을 때 하단에 표시)
struct BuildingTypeFilterView: View {
    @Binding var selectedBuildingTypes: Set<BuildingType>
    
    private var isAllSelected: Bool {
        selectedBuildingTypes.count == BuildingType.mapFilterTypes.count
    }
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                // 전체 선택/해제
                Button {
                    if isAllSelected {
                        selectedBuildingTypes.removeAll()
                    } else {
                        selectedBuildingTypes = Set(BuildingType.mapFilterTypes)
                    }
                } label: {
                    Text("전체")
                        .font(.caption2)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .fill(isAllSelected ? Color.blue : Color(.systemGray6))
                        )
                        .foregroundStyle(isAllSelected ? .white : .primary)
                }
                
                // 아파트, 연립다세대만 표시
                ForEach(BuildingType.mapFilterTypes, id: \.self) { type in
                    BuildingTypeChip(
                        type: type,
                        isSelected: selectedBuildingTypes.contains(type)
                    ) {
                        if selectedBuildingTypes.contains(type) {
                            selectedBuildingTypes.remove(type)
                        } else {
                            selectedBuildingTypes.insert(type)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
}

/// 건물 타입 칩
struct BuildingTypeChip: View {
    let type: BuildingType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: iconName(for: type))
                    .font(.caption2)
                Text(type.displayName)
                    .font(.caption2)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue.opacity(0.8) : Color(.systemGray5))
            )
            .foregroundStyle(isSelected ? .white : .primary)
        }
    }
    
    private func iconName(for type: BuildingType) -> String {
        switch type {
        case .apartment:
            return "building.2.fill"
        case .officetel:
            return "building.fill"
        case .villa:
            return "house.fill"
        case .rowHouse:
            return "house.and.flag.fill"
        case .house:
            return "house.circle.fill"
        case .commercial:
            return "storefront.fill"
        }
    }
}

#Preview {
    BuildingTypeFilterView(
        selectedBuildingTypes: .constant(Set(BuildingType.mapFilterTypes))
    )
}
