//
//  BuildingRowView.swift
//  AreaPulse
//
//  Created by 바견규 on 12/1/25.
//

import SwiftUI

// MARK: - Building Row View

struct BuildingRowView: View {
    let building: Building
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "building.2.fill")
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(building.buildingName ?? "이름 없음")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                Text(building.address ?? "주소 없음")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(building.buildingType.displayName)
                    .font(.caption2)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(Color.blue.opacity(0.2))
                    )
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}
