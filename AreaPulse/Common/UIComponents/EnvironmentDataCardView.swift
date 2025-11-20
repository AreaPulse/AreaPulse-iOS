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
            
            if let pm10 = data.pm10Value {
                HStack {
                    Image(systemName: "aqi.medium")
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("미세먼지")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(pm10)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("㎍/㎥")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(data.pm10Grade)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(gradeColor(for: data.pm10Grade)))
                        }
                    }
                    
                    Spacer()
                }
            }
            
            if let pm25 = data.pm25Value {
                HStack {
                    Image(systemName: "aqi.low")
                        .foregroundStyle(.purple)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("초미세먼지")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(pm25)")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("㎍/㎥")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            Text(data.pm25Grade)
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Capsule().fill(gradeColor(for: data.pm25Grade)))
                        }
                    }
                    
                    Spacer()
                }
            }
            
            if let noise = data.noiseDb {
                HStack {
                    Image(systemName: "waveform")
                        .foregroundStyle(.orange)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("소음")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        HStack(alignment: .firstTextBaseline, spacing: 4) {
                            Text("\(noise, specifier: "%.1f")")
                                .font(.title3)
                                .fontWeight(.semibold)
                            
                            Text("dB")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Spacer()
                }
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
    
    private func gradeColor(for grade: String) -> Color {
        switch grade {
        case "좋음": 
            return .green.opacity(0.2)
        case "보통": 
            return .yellow.opacity(0.2)
        case "나쁨": 
            return .orange.opacity(0.2)
        case "매우나쁨": 
            return .red.opacity(0.2)
        case "정보없음":
            return .gray.opacity(0.2)
        default: 
            return .gray.opacity(0.2)
        }
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 16) {
            EnvironmentDataCardView(data: EnvironmentData(
                id: 1,
                stationId: 1,
                measurementTime: Date(),
                pm10Value: 35,
                pm25Value: 15,
                noiseDb: 55.5
            ))
            
            EnvironmentDataCardView(data: EnvironmentData(
                id: 2,
                stationId: 2,
                measurementTime: Date(),
                pm10Value: 85,
                pm25Value: 45,
                noiseDb: 72.3
            ))
        }
        .padding()
    }
    .background(Color(.systemGroupedBackground))
}
