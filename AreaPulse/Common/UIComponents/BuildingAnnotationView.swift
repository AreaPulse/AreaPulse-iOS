//
//  BuildingAnnotationView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI
import MapKit

/// 지도 상의 건물 마커 뷰
struct BuildingAnnotationView: View {
    let building: Building
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: "building.2.fill")
                .font(.title3)
                .foregroundStyle(isSelected ? .blue : .red)
                .padding(8)
                .background(Circle().fill(.white))
                .shadow(radius: 2)
            
            if isSelected, let name = building.buildingName {
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.white)
                            .shadow(radius: 2)
                    )
            }
        }
    }
}
