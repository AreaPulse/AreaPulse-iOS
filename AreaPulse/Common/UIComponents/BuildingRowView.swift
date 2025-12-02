//
//  BuildingRowView.swift
//  AreaPulse
//
//  Created by 바견규 on 12/1/25.
//

import SwiftUI
import CoreLocation

// MARK: - Building Row View (Updated)

struct BuildingRowView: View {
    let building: Building
    var referenceCoordinate: CLLocationCoordinate2D?
    
    var body: some View {
        HStack(spacing: 12) {
            // 건물 타입 아이콘
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "building.2.fill")
                    .foregroundStyle(.blue)
            }
            
            // 건물 정보
            VStack(alignment: .leading, spacing: 4) {
                Text(building.buildingName ?? "이름 없음")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.primary)
                
                HStack(spacing: 8) {
                    Text(building.buildingType.displayName)
                        .font(.caption)
                        .foregroundStyle(.blue)
                    
                    if let address = building.address {
                        Text(address)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            }
            
            Spacer()
            
            // 거리 표시
            if let refCoord = referenceCoordinate {
                let distance = calculateDistance(from: refCoord, to: building.coordinate)
                HStack(spacing: 2) {
                    Image(systemName: "figure.walk")
                        .font(.caption2)
                    Text(formatDistance(distance))
                        .font(.caption)
                }
                .foregroundStyle(.blue)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
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
