//
//  InfraStructureRowView.swift
//  AreaPulse
//
//  Created by 바견규 on 12/1/25.
//

import SwiftUI
import CoreLocation

// MARK: - Infrastructure Row View (Updated)

struct InfrastructureRowView: View {
    let infrastructure: Infrastructure
    var referenceCoordinate: CLLocationCoordinate2D?
    
    var body: some View {
        HStack(spacing: 12) {
            // 카테고리 아이콘
            Image(systemName: infrastructure.category.iconName)
                .font(.title3)
                .foregroundStyle(.blue)
                .frame(width: 32)
            
            // 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(infrastructure.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                if let address = infrastructure.address {
                    Text(address)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // 거리 표시
            if let refCoord = referenceCoordinate {
                let distance = calculateDistance(from: refCoord, to: infrastructure.coordinate)
                HStack(spacing: 2) {
                    Image(systemName: "figure.walk")
                        .font(.caption2)
                    Text(formatDistance(distance))
                        .font(.caption)
                }
                .foregroundStyle(.blue)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemBackground))
        )
    }
    
    private func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        } else {
            return String(format: "%.1fkm", meters / 1000)
        }
    }
}


