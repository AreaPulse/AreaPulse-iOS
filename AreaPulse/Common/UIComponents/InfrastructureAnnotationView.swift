//
//  InfrastructureAnnotationView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 지도 상의 인프라 마커 뷰
struct InfrastructureAnnotationView: View {
    let infrastructure: Infrastructure
    
    var body: some View {
        VStack(spacing: 0) {
            Image(systemName: infrastructure.category.iconName)
                .font(.caption)
                .foregroundStyle(.white)
                .padding(6)
                .background(Circle().fill(categoryColor))
                .shadow(radius: 2)
        }
    }
    
    private var categoryColor: Color {
        switch infrastructure.category {
        case .school: return .blue
        case .park: return .green
        case .subwayStation: return .orange
        case .busStop: return .yellow
        case .hospital: return .red
        case .mart: return .purple
        case .bank: return .indigo
        case .publicOffice: return .gray
        case .cctv: return .black
        }
    }
}
