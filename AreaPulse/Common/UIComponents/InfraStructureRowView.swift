//
//  InfraStructureRowView.swift
//  AreaPulse
//
//  Created by 바견규 on 12/1/25.
//

import SwiftUI

// MARK: - Infrastructure Row View

struct InfrastructureRowView: View {
    let infrastructure: Infrastructure
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: infrastructure.category.iconName)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(infrastructure.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(infrastructure.address ?? "주소 정보 없음")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
  
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.tertiarySystemBackground))
        )
    }
}
