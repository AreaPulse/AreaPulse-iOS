//
//  EnvironmentDataCard.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 환경 데이터 카드 뷰
struct EnvironmentDataCardView: View {
    let data: EnvironmentData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("환경 정보")
                .font(.headline)
                .fontWeight(.bold)
            
            // 주소 정보
            HStack {
                Image(systemName: "location.fill")
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("주소")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(data.address)
                        .font(.subheadline)
                        .fontWeight(.medium)
                }
                
                Spacer()
            }
            
            Divider()
            
            // 평균 소음
            HStack {
                Image(systemName: "waveform")
                    .foregroundStyle(.orange)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("평균 소음")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 4) {
                        Text("\(data.noiseAvg, specifier: "%.1f")")
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text("dB")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(data.noiseGrade)
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(gradeColor(for: data.noiseGrade)))
                    }
                }
                
                Spacer()
            }
            
            // 최대/최소 소음
            HStack(spacing: 24) {
                // 최대 소음
                VStack(alignment: .leading, spacing: 4) {
                    Text("최대")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(data.noiseMax, specifier: "%.1f")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("dB")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 최소 소음
                VStack(alignment: .leading, spacing: 4) {
                    Text("최소")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text("\(data.noiseMin, specifier: "%.1f")")
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Text("dB")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.leading, 28) // Align with other content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 4, y: 2)
        )
    }
    
    private func gradeColor(for grade: String) -> Color {
        switch grade {
        case "조용함": 
            return .green.opacity(0.2)
        case "보통": 
            return .blue.opacity(0.2)
        case "다소 시끄러움": 
            return .yellow.opacity(0.2)
        case "시끄러움": 
            return .orange.opacity(0.2)
        case "매우 시끄러움": 
            return .red.opacity(0.2)
        default: 
            return .gray.opacity(0.2)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            EnvironmentDataCardView(data: EnvironmentData(
                address: "서울특별시 강남구 역삼동",
                noiseMax: 72.5,
                noiseAvg: 55.5,
                noiseMin: 42.3,
                latitude: 37.5665,
                longitude: 126.9780
            ))
            
            EnvironmentDataCardView(data: EnvironmentData(
                address: "서울특별시 종로구 청와대로",
                noiseMax: 85.2,
                noiseAvg: 72.3,
                noiseMin: 58.1,
                latitude: 37.5796,
                longitude: 126.9770
            ))
            
            EnvironmentDataCardView(data: EnvironmentData(
                address: "서울특별시 마포구 상암동",
                noiseMax: 52.1,
                noiseAvg: 45.8,
                noiseMin: 38.5,
                latitude: 37.5794,
                longitude: 126.8895
            ))
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
