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
    let statsType: RegionStatsDisplayType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: statsType.iconName)
                    .font(.title3)
                    .foregroundStyle(statsType.iconColor)
                
                Text(statsType.title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(statsType.formattedValue(from: stats))
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(statsType.unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            if let subtitle = statsType.subtitle(from: stats) {
                Text(subtitle)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
    }
}

/// 지역 통계 표시 타입
enum RegionStatsDisplayType {
    case crime
    case cctv
    case dangerousRating
    case cctvSecurityRating
    case passenger
    case complexityRating
    
    var title: String {
        switch self {
        case .crime: return "범죄 발생"
        case .cctv: return "CCTV 수"
        case .dangerousRating: return "위험도"
        case .cctvSecurityRating: return "CCTV 보안등급"
        case .passenger: return "유동인구"
        case .complexityRating: return "복잡도"
        }
    }
    
    var unit: String {
        switch self {
        case .crime: return "건"
        case .cctv: return "대"
        case .dangerousRating, .cctvSecurityRating, .complexityRating: return "점"
        case .passenger: return "명"
        }
    }
    
    var iconName: String {
        switch self {
        case .crime: return "exclamationmark.shield.fill"
        case .cctv: return "video.fill"
        case .dangerousRating: return "exclamationmark.triangle.fill"
        case .cctvSecurityRating: return "checkmark.shield.fill"
        case .passenger: return "figure.walk"
        case .complexityRating: return "chart.bar.fill"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .crime, .dangerousRating: return .red
        case .cctv, .cctvSecurityRating: return .green
        case .passenger: return .blue
        case .complexityRating: return .orange
        }
    }
    
    func formattedValue(from stats: RegionStats) -> String {
        switch self {
        case .crime:
            guard let value = stats.crimeNum else { return "-" }
            return "\(value)"
        case .cctv:
            guard let value = stats.cctvNum else { return "-" }
            return "\(value)"
        case .dangerousRating:
            guard let value = stats.dangerousRating else { return "-" }
            return String(format: "%.1f", value)
        case .cctvSecurityRating:
            guard let value = stats.cctvSecurityRating else { return "-" }
            return String(format: "%.1f", value)
        case .passenger:
            guard let value = stats.passengerNum else { return "-" }
            return "\(value)"
        case .complexityRating:
            guard let value = stats.complexityRating else { return "-" }
            return String(format: "%.1f", value)
        }
    }
    
    func subtitle(from stats: RegionStats) -> String? {
        switch self {
        case .cctv:
            return "500m 이내"
        default:
            return stats.regionName
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        StatsCardView(
            stats: RegionStats(
                regionName: "강남구 역삼동",
                crimeNum: 125,
                cctvNum: 450,
                dangerousRating: 3.2,
                cctvSecurityRating: 4.5,
                passengerNum: 15000,
                complexityRating: 7.8
            ),
            statsType: .crime
        )
        
        StatsCardView(
            stats: RegionStats(
                regionName: "강남구 역삼동",
                crimeNum: 125,
                cctvNum: 450,
                dangerousRating: 3.2,
                cctvSecurityRating: 4.5,
                passengerNum: 15000,
                complexityRating: 7.8
            ),
            statsType: .cctv
        )
        
        StatsCardView(
            stats: RegionStats(
                regionName: "강남구 역삼동",
                crimeNum: 125,
                cctvNum: 450,
                dangerousRating: 3.2,
                cctvSecurityRating: 4.5,
                passengerNum: 15000,
                complexityRating: 7.8
            ),
            statsType: .dangerousRating
        )
    }
    .padding()
    .background(Color(.systemGroupedBackground))
}
