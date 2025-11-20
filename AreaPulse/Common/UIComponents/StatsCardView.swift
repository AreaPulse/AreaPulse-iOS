//
//  StatsCard.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 지역 통계 카드 뷰
struct StatsCardView: View {
    let stats: RegionStats
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: iconName)
                    .font(.title3)
                    .foregroundStyle(iconColor)
                
                Text(stats.statsType.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text("\(stats.statsValue, specifier: "%.1f")")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(stats.statsType.unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Text("\(stats.statsYear)년 기준")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
    }
    
    private var iconName: String {
        switch stats.statsType {
        case .crimeTotal, .crimeTheft: return "exclamationmark.shield.fill"
        case .noiseDay, .noiseNight: return "waveform"
        }
    }
    
    private var iconColor: Color {
        switch stats.statsType {
        case .crimeTotal, .crimeTheft: return .red
        case .noiseDay, .noiseNight: return .orange
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        StatsCardView(stats: RegionStats(
            id: 1,
            bjdCode: "1111010100",
            statsYear: 2024,
            statsType: .crimeTotal,
            statsValue: 125.5
        ))
        
        StatsCardView(stats: RegionStats(
            id: 2,
            bjdCode: "1111010100",
            statsYear: 2024,
            statsType: .noiseDay,
            statsValue: 65.3
        ))
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
