//
//  NavigationRoutingView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 앱 내에서 특정 화면으로의 이동을 처리하는 라우팅 뷰입니다.
/// `NavigationDestination` enum 값을 기준으로 적절한 화면을 렌더링합니다.
struct NavigationRoutingView: View {
    
    /// DI 컨테이너: 의존성 주입을 위한 환경 객체
    @EnvironmentObject var container: DIContainer
    
    /// 현재 이동할 화면을 나타내는 상태값
    @State var destination: NavigationDestination
    
    // MARK: - Body
    var body: some View {
        destinationView
            // 각 하위 뷰에도 DIContainer를 공유해줌
            .environmentObject(container)
    }
    
    @ViewBuilder
    private var destinationView: some View {
        switch destination {
        case .contentView:
            ContentView()
        // MARK: - Map Tab
        case .map:
            MapView(navigationRouter: container.navigationRouter)
            
        case .buildingDetail(let buildingId):
            BuildingDetailView(
                buildingId: buildingId,
                navigationRouter: container.navigationRouter
            )
            
        case .pointSearchResult(let latitude, let longitude):
            PointSearchResultView(
                latitude: latitude,
                longitude: longitude,
                navigationRouter: container.navigationRouter
            )
            
        case .reviewWrite(let buildingId):
            ReviewWriteView(
                buildingId: buildingId,
                navigationRouter: container.navigationRouter
            )
            
        case .reviewList(let buildingId):
            ReviewListView(buildingId: buildingId)
            
        // MARK: - Saved Tab
        case .savedBuildings:
            SavedBuildingsView(
                navigationRouter: container.navigationRouter
            )
            
        case .savedBuildingDetail(let saveId):
            // saveId를 통해 buildingId를 조회하거나, 직접 buildingId를 전달받아야 함
            // 임시로 saveId를 buildingId로 사용
            BuildingDetailView(
                buildingId: saveId,
                navigationRouter: container.navigationRouter
            )
            
        // MARK: - Profile Tab
        case .profile:
            ProfileView()
                .environmentObject(container.authManager)
            
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    NavigationRoutingView(destination: .contentView)
        .environmentObject(DIContainer())
}
