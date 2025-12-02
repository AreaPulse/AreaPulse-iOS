//
//  SubwayLineParser.swift
//  AreaPulse
//
//  Created by 바견규 on 12/01/24.
//

import Foundation
import SwiftUI

/// 지하철 노선 정보
enum SubwayLine: String, CaseIterable {
    case line1 = "1호선"
    case line2 = "2호선"
    case line3 = "3호선"
    case line4 = "4호선"
    case line5 = "5호선"
    case line6 = "6호선"
    case line7 = "7호선"
    case line8 = "8호선"
    case line9 = "9호선"
    case airport = "공항철도"
    case gyeongui = "경의중앙선"
    case gyeongchun = "경춘선"
    case suin = "수인분당선"
    case sinbundang = "신분당선"
    case gyeonggang = "경강선"
    case seohae = "서해선"
    case incheon1 = "인천1호선"
    case incheon2 = "인천2호선"
    case everline = "에버라인"
    case uijeongbu = "의정부경전철"
    case unknown = "미확인"
    
    var color: Color {
        switch self {
        case .line1: return Color(red: 0/255, green: 52/255, blue: 120/255) // 진한 파랑
        case .line2: return Color(red: 0/255, green: 168/255, blue: 107/255) // 초록
        case .line3: return Color(red: 255/255, green: 99/255, blue: 32/255) // 주황
        case .line4: return Color(red: 0/255, green: 149/255, blue: 217/255) // 하늘색
        case .line5: return Color(red: 147/255, green: 112/255, blue: 219/255) // 보라
        case .line6: return Color(red: 205/255, green: 133/255, blue: 63/255) // 갈색
        case .line7: return Color(red: 84/255, green: 96/255, blue: 49/255) // 올리브
        case .line8: return Color(red: 231/255, green: 56/255, blue: 138/255) // 핑크
        case .line9: return Color(red: 186/255, green: 162/255, blue: 106/255) // 금색
        case .airport: return Color(red: 0/255, green: 159/255, blue: 218/255) // 하늘색
        case .gyeongui: return Color(red: 119/255, green: 197/255, blue: 213/255) // 청록
        case .gyeongchun: return Color(red: 0/255, green: 180/255, blue: 140/255) // 민트
        case .suin: return Color(red: 251/255, green: 176/255, blue: 59/255) // 노랑
        case .sinbundang: return Color(red: 211/255, green: 44/255, blue: 49/255) // 빨강
        case .gyeonggang: return Color(red: 0/255, green: 101/255, blue: 189/255) // 파랑
        case .seohae: return Color(red: 126/255, green: 204/255, blue: 73/255) // 연두
        case .incheon1: return Color(red: 126/255, green: 186/255, blue: 229/255) // 하늘색
        case .incheon2: return Color(red: 246/255, green: 181/255, blue: 0/255) // 노랑
        case .everline: return Color(red: 119/255, green: 201/255, blue: 66/255) // 연두
        case .uijeongbu: return Color(red: 255/255, green: 165/255, blue: 0/255) // 주황
        case .unknown: return .gray
        }
    }
    
    var shortName: String {
        switch self {
        case .line1: return "1"
        case .line2: return "2"
        case .line3: return "3"
        case .line4: return "4"
        case .line5: return "5"
        case .line6: return "6"
        case .line7: return "7"
        case .line8: return "8"
        case .line9: return "9"
        case .airport: return "공항"
        case .gyeongui: return "경의"
        case .gyeongchun: return "경춘"
        case .suin: return "수인"
        case .sinbundang: return "신분당"
        case .gyeonggang: return "경강"
        case .seohae: return "서해"
        case .incheon1: return "인천1"
        case .incheon2: return "인천2"
        case .everline: return "에버"
        case .uijeongbu: return "의정부"
        case .unknown: return "?"
        }
    }
}

/// 지하철역 이름에서 노선 정보를 파싱하는 유틸리티
struct SubwayLineParser {
    
    /// 지하철역 이름에서 노선 정보를 추출합니다
    /// - Parameter stationName: 지하철역 이름 (예: "강남역(2호선,신분당선)")
    /// - Returns: 파싱된 노선 배열
    static func parseLines(from stationName: String) -> [SubwayLine] {
        var lines: [SubwayLine] = []
        
        // 괄호 안의 내용 추출
        if let range = stationName.range(of: "\\([^)]+\\)", options: .regularExpression) {
            let content = String(stationName[range])
                .replacingOccurrences(of: "(", with: "")
                .replacingOccurrences(of: ")", with: "")
            
            // 쉼표로 분리
            let lineStrings = content.components(separatedBy: ",")
            
            for lineString in lineStrings {
                let trimmed = lineString.trimmingCharacters(in: .whitespaces)
                
                // 각 노선 매칭
                for line in SubwayLine.allCases {
                    if trimmed.contains(line.rawValue) || 
                       trimmed.contains(line.shortName + "호선") {
                        lines.append(line)
                        break
                    }
                }
            }
        }
        
        // 노선 정보가 없으면 역 이름에서 직접 파싱 시도
        if lines.isEmpty {
            for line in SubwayLine.allCases where line != .unknown {
                if stationName.contains(line.rawValue) || 
                   stationName.contains(line.shortName + "호선") {
                    lines.append(line)
                }
            }
        }
        
        return lines.isEmpty ? [.unknown] : lines
    }
    
    /// 역 이름에서 순수한 이름만 추출합니다 (노선 정보 제거)
    /// - Parameter stationName: 지하철역 이름
    /// - Returns: 순수한 역 이름
    static func extractStationName(from stationName: String) -> String {
        // 괄호와 그 안의 내용 제거
        let pattern = "\\([^)]+\\)"
        let cleanName = stationName.replacingOccurrences(
            of: pattern,
            with: "",
            options: .regularExpression
        ).trimmingCharacters(in: .whitespaces)
        
        return cleanName
    }
}

/// 지하철 노선 뷰 컴포넌트
struct SubwayLineTag: View {
    let line: SubwayLine
    let compact: Bool
    
    init(line: SubwayLine, compact: Bool = false) {
        self.line = line
        self.compact = compact
    }
    
    var body: some View {
        Text(compact ? line.shortName : line.rawValue)
            .font(compact ? .caption2 : .caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, compact ? 6 : 8)
            .padding(.vertical, compact ? 2 : 4)
            .background(line.color)
            .cornerRadius(compact ? 4 : 6)
    }
}

/// 여러 노선을 표시하는 뷰
struct SubwayLinesView: View {
    let lines: [SubwayLine]
    let compact: Bool
    
    init(lines: [SubwayLine], compact: Bool = false) {
        self.lines = lines
        self.compact = compact
    }
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(lines, id: \.self) { line in
                SubwayLineTag(line: line, compact: compact)
            }
        }
    }
}

#Preview {
    VStack(spacing: 16) {
        // 예시 1: 강남역
        VStack(alignment: .leading) {
            Text("강남역")
                .font(.headline)
            SubwayLinesView(lines: [.line2, .sinbundang])
        }
        
        // 예시 2: 서울역
        VStack(alignment: .leading) {
            Text("서울역")
                .font(.headline)
            SubwayLinesView(lines: [.line1, .line4, .airport, .gyeongui])
        }
        
        // 예시 3: Compact 모드
        VStack(alignment: .leading) {
            Text("홍대입구역 (Compact)")
                .font(.headline)
            SubwayLinesView(
                lines: [.line2, .airport, .gyeongui],
                compact: true
            )
        }
    }
    .padding()
}
