//
//  MainTabView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 메인 탭바 화면
struct MainTabView: View {
    @State private var selectedTab: Tab = .map
    @Bindable var navigationRouter: NavigationRouter
    
    enum Tab {
        case map
        case saved
        case profile
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 지도 탭
            NavigationStack(path: $navigationRouter.destination) {
                MapView(navigationRouter: navigationRouter)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("지도", systemImage: "map")
            }
            .tag(Tab.map)
            
            // 찜 목록 탭
            NavigationStack {
                SavedBuildingsView(navigationRouter: navigationRouter)
            }
            .tabItem {
                Label("찜", systemImage: "heart")
            }
            .tag(Tab.saved)
            
            // 프로필 탭
            NavigationStack {
                ProfileView()
            }
            .tabItem {
                Label("프로필", systemImage: "person")
            }
            .tag(Tab.profile)
        }
    }
    
    @ViewBuilder
    private func destinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .contentView:
            ContentView()
            
        case .map:
            MapView(navigationRouter: navigationRouter)
            
        case .buildingDetail(let buildingId):
            BuildingDetailView(buildingId: buildingId, navigationRouter: navigationRouter)
            
        case .pointSearchResult(let latitude, let longitude):
            Text("Point Search Result: \(latitude), \(longitude)")
            
        case .reviewWrite(let buildingId):
            ReviewWriteView(buildingId: buildingId, navigationRouter: navigationRouter)
            
        case .reviewList(let buildingId):
            ReviewListView(buildingId: buildingId)
            
        case .savedBuildings:
            SavedBuildingsView(navigationRouter: navigationRouter)
            
        case .savedBuildingDetail(let saveId):
            Text("Saved Building Detail: \(saveId)")
            
        case .profile:
            ProfileView()
            
        case .settings:
            SettingsView()
        }
    }
}

#Preview {
    MainTabView(navigationRouter: NavigationRouter())
}
