# 통근 시간 계산 및 지하철 노선 정보 기능 가이드

## 📋 개요

이 기능은 사용자가 마이페이지에서 직장 주소를 설정하면, 건물 상세 화면에서 해당 건물까지의 통근 시간을 자동으로 계산해주는 기능입니다.

### 주요 기능

1. **직장 주소 설정** - MapKit Search를 사용한 주소 검색 및 저장
2. **통근 시간 계산** - MapKit Directions API를 사용한 실시간 경로 계산
3. **지하철 노선 정보** - 역 이름에서 노선 정보 파싱 및 시각화
4. **생활 편의시설 요약** - 근처 학교, 공원, 버스정류장 개수 표시

## 🗂 파일 구조

```
AreaPulse/
├── Service/
│   └── CommuteCalculator.swift          # 통근 시간 계산 로직
├── Utils/
│   └── SubwayLineParser.swift           # 지하철 노선 파싱 유틸리티
├── Views/
│   ├── CommuteInfoView.swift            # 통근 정보 UI 컴포넌트
│   ├── ProfileView.swift                # 직장 주소 설정 UI
│   └── BuildingDetailViewExample.swift  # 사용 예시
└── Managers/
    └── AuthManager.swift                # 직장 정보 저장 (업데이트됨)
```

## 🚀 사용 방법

### 1. 직장 주소 설정

사용자는 프로필 화면에서 직장 주소를 설정할 수 있습니다:

```swift
// ProfileView.swift에서 자동으로 제공
// 사용자가 "직장 주소 설정하기" 버튼을 누르면
// WorkplaceSettingView가 표시됩니다

struct ProfileView: View {
    @EnvironmentObject private var authManager: AuthManager
    // ...
}
```

### 2. 건물 상세 화면에 통근 정보 추가

```swift
import SwiftUI
import CoreLocation

struct BuildingDetailView: View {
    let building: Building
    @EnvironmentObject private var authManager: AuthManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 기존 건물 정보
                
                // 🆕 통근 시간 정보 추가
                CommuteInfoView(
                    buildingCoordinate: CLLocationCoordinate2D(
                        latitude: building.latitude,
                        longitude: building.longitude
                    )
                )
                
                // 🆕 근처 지하철역 (노선 정보 포함)
                NearbySubwayStationsView(stations: nearbySubwayStations)
                
                // 🆕 생활 편의시설 요약
                InfrastructureSummaryView(
                    schools: nearbySchools.count,
                    parks: nearbyParks.count,
                    busStops: nearbyBusStops.count
                )
                
                // 기존 컨텐츠들...
            }
            .padding()
        }
    }
}
```

### 3. 지하철 노선 정보 파싱

역 이름에서 노선 정보를 자동으로 추출합니다:

```swift
// 예시: "강남역(2호선,신분당선)"
let stationName = "강남역(2호선,신분당선)"

// 노선 정보 추출
let lines = SubwayLineParser.parseLines(from: stationName)
// 결과: [.line2, .sinbundang]

// 순수한 역 이름만 추출
let cleanName = SubwayLineParser.extractStationName(from: stationName)
// 결과: "강남역"

// UI에 표시
SubwayLinesView(lines: lines)
```

### 4. 통근 시간 직접 계산

필요한 경우 직접 통근 시간을 계산할 수도 있습니다:

```swift
let calculator = CommuteCalculator()

// 단일 교통수단
let commuteInfo = try await calculator.calculateCommute(
    from: buildingCoordinate,
    to: workplaceCoordinate,
    transportType: .transit // 대중교통
)

print("소요 시간: \(commuteInfo.formattedDuration)")
print("거리: \(commuteInfo.formattedDistance)")

// 모든 교통수단
let allCommutes = try await calculator.calculateAllCommutes(
    from: buildingCoordinate,
    to: workplaceCoordinate
)

for commute in allCommutes {
    print("\(commute.transportName): \(commute.formattedDuration)")
}
```

## 🎨 UI 컴포넌트

### CommuteInfoView

통근 시간을 표시하는 메인 컴포넌트입니다.

**특징:**
- 직장 주소가 설정되어 있으면 자동으로 통근 시간 계산
- 대중교통, 자동차, 도보(3km 이내) 정보 표시
- 직장 주소가 없으면 설정 유도 UI 표시
- 자동 새로고침 기능

### SubwayLineTag / SubwayLinesView

지하철 노선을 시각적으로 표시하는 컴포넌트입니다.

**지원 노선:**
- 서울 지하철 1~9호선
- 공항철도, 경의중앙선, 경춘선
- 수인분당선, 신분당선
- 경강선, 서해선
- 인천 1,2호선
- 에버라인, 의정부경전철

**사용 예시:**
```swift
// 단일 노선
SubwayLineTag(line: .line2)

// 여러 노선
SubwayLinesView(lines: [.line2, .sinbundang])

// 컴팩트 모드
SubwayLinesView(lines: [.line1, .line4], compact: true)
```

### NearbySubwayStationsView

근처 지하철역 목록과 노선 정보를 표시합니다.

### InfrastructureSummaryView

주변 생활 편의시설 개수를 한눈에 볼 수 있는 요약 뷰입니다.

## 📊 추가된 유용한 정보

### 1. 통근 시간 (CommuteInfoView)
- **대중교통**: 지하철, 버스 등을 이용한 경로
- **자동차**: 차량 이용 시 예상 시간
- **도보**: 3km 이내인 경우 도보 시간

### 2. 지하철 접근성
- **근처 지하철역**: 거리순으로 정렬
- **노선 정보**: 각 역의 환승 가능 노선 표시
- **주소 정보**: 역의 정확한 위치

### 3. 생활 편의시설
- **학교**: 근처 교육시설 개수
- **공원**: 근처 공원 및 녹지 공간
- **버스 정류장**: 대중교통 접근성

## ⚙️ 설정 및 권한

### 필요한 권한

**Info.plist에 추가:**
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>건물까지의 통근 시간을 계산하기 위해 위치 정보가 필요합니다.</string>
```

### MapKit 프레임워크

이미 프로젝트에 포함되어 있어야 합니다:
```swift
import MapKit
import CoreLocation
```

## 🔧 커스터마이징

### 지하철 노선 색상 변경

`SubwayLineParser.swift`에서 각 노선의 색상을 수정할 수 있습니다:

```swift
enum SubwayLine {
    case line2
    
    var color: Color {
        switch self {
        case .line2: 
            return Color(red: 0/255, green: 168/255, blue: 107/255) // 초록색
        }
    }
}
```

### 통근 시간 계산 방식 변경

`CommuteCalculator.swift`에서 계산 로직을 수정할 수 있습니다:

```swift
func calculateCommute(
    from: CLLocationCoordinate2D,
    to: CLLocationCoordinate2D,
    transportType: MKDirectionsTransportType = .automobile
) async throws -> CommuteInfo {
    let request = MKDirections.Request()
    request.source = MKMapItem(placemark: MKPlacemark(coordinate: from))
    request.destination = MKMapItem(placemark: MKPlacemark(coordinate: to))
    request.transportType = transportType
    
    // 추가 옵션 설정 가능
    // request.requestsAlternateRoutes = true
    // request.departureDate = Date()
    
    // ...
}
```

## 🐛 트러블슈팅

### 통근 시간이 계산되지 않음

**원인:**
- 직장 주소가 설정되지 않음
- 좌표가 유효하지 않음
- MapKit 서비스 오류

**해결 방법:**
```swift
// 직장 정보 확인
if let workplace = authManager.workplaceInfo {
    print("직장: \(workplace.address)")
    print("좌표: \(workplace.latitude), \(workplace.longitude)")
} else {
    print("직장 주소가 설정되지 않았습니다")
}
```

### 지하철 노선이 제대로 파싱되지 않음

**원인:**
- 역 이름 형식이 예상과 다름
- 새로운 노선이 추가됨

**해결 방법:**
1. `SubwayLine` enum에 새 노선 추가
2. `parseLines` 메서드의 파싱 로직 수정

```swift
// 디버깅
let lines = SubwayLineParser.parseLines(from: stationName)
print("파싱된 노선: \(lines)")

if lines.contains(.unknown) {
    print("⚠️ 인식되지 않은 노선이 있습니다: \(stationName)")
}
```

## 📈 성능 최적화

### 1. 캐싱

통근 시간은 자주 변하지 않으므로 캐싱을 고려할 수 있습니다:

```swift
actor CommuteCache {
    private var cache: [String: CommuteInfo] = [:]
    
    func get(key: String) -> CommuteInfo? {
        cache[key]
    }
    
    func set(key: String, value: CommuteInfo) {
        cache[key] = value
    }
}
```

### 2. 백그라운드 계산

무거운 계산은 백그라운드에서 수행:

```swift
Task.detached(priority: .userInitiated) {
    let commutes = try await calculator.calculateAllCommutes(
        from: from,
        to: to
    )
    
    await MainActor.run {
        // UI 업데이트
    }
}
```

## 🎯 다음 단계

### 추가 가능한 기능

1. **출퇴근 시간대 고려**
   - 러시아워 시간대의 교통 상황 반영
   - 시간대별 통근 시간 비교

2. **경로 상세 정보**
   - 환승 정보
   - 단계별 안내

3. **알림 기능**
   - 출발 시간 알림
   - 교통 상황 변화 알림

4. **통계 기능**
   - 평균 통근 시간
   - 월별 통근 비용 계산

## 📝 라이선스

이 코드는 AreaPulse 프로젝트의 일부입니다.

## 👥 기여자

Created by 바견규 on 12/01/24.
