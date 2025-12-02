//
//  NavigateToWorkplaceButton.swift
//  AreaPulse
//

import SwiftUI
import MapKit

struct NavigateToWorkplaceButton: View {
    @EnvironmentObject private var authManager: AuthManager
    
    let buildingCoordinate: CLLocationCoordinate2D
    let buildingName: String
    
    @State private var showMapSelection = false
    @State private var showWorkplaceAlert = false
    
    private var hasWorkplace: Bool {
        authManager.workplaceInfo != nil
    }
    
    var body: some View {
        Button {
            if hasWorkplace {
                showMapSelection = true
            } else {
                showWorkplaceAlert = true
            }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                Text("직장까지 길찾기")
                Spacer()
                if !hasWorkplace {
                    Text("등록 필요")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.7))
                } else {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                }
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundStyle(.white)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(hasWorkplace ? Color.blue : Color.gray)
            )
        }
        .confirmationDialog("지도 앱 선택", isPresented: $showMapSelection) {
            if let workplace = authManager.workplaceInfo {
                ForEach(NavigationHelper.availableApps) { app in
                    Button(app.rawValue) {
                        NavigationHelper.openNavigation(
                            to: (workplace.latitude, workplace.longitude, workplace.address),
                            from: (buildingCoordinate.latitude, buildingCoordinate.longitude),
                            app: app
                        )
                    }
                }
                
                ForEach(MapApp.allCases.filter { !NavigationHelper.isAppInstalled($0) }) { app in
                    Button("\(app.rawValue) 설치하기") {
                        NavigationHelper.openNavigation(
                            to: (0, 0, ""),
                            app: app
                        )
                    }
                }
            }
            
            Button("취소", role: .cancel) {}
        } message: {
            Text("직장까지 길찾기")
        }
        .alert("직장 등록 필요", isPresented: $showWorkplaceAlert) {
            Button("나중에", role: .cancel) {}
            Button("등록하러 가기") {
                // 프로필 탭으로 이동하거나 시트 띄우기
                NotificationCenter.default.post(name: .openWorkplaceSetting, object: nil)
            }
        } message: {
            Text("직장 주소를 등록하면 출퇴근 길찾기를 이용할 수 있어요.")
        }
    }
}

// Notification 이름 추가
extension Notification.Name {
    static let openWorkplaceSetting = Notification.Name("openWorkplaceSetting")
}
