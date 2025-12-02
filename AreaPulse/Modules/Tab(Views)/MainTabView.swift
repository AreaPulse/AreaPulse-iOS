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
    
    // 각 탭별 네비게이션 경로
    @State private var mapPath: [NavigationDestination] = []
    @State private var savedPath: [NavigationDestination] = []
    @State private var profilePath: [NavigationDestination] = []
    
    enum Tab {
        case map
        case saved
        case profile
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 지도 탭
            NavigationStack(path: $mapPath) {
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
            NavigationStack(path: $savedPath) {
                SavedBuildingsView(navigationRouter: navigationRouter)
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("찜", systemImage: "heart")
            }
            .tag(Tab.saved)
            
            // 프로필 탭
            NavigationStack(path: $profilePath) {
                ProfileView()
                    .navigationDestination(for: NavigationDestination.self) { destination in
                        destinationView(for: destination)
                    }
            }
            .tabItem {
                Label("프로필", systemImage: "person")
            }
            .tag(Tab.profile)
        }
        .onChange(of: navigationRouter.destination) { oldValue, newValue in
            // NavigationRouter에서 push가 발생하면 현재 탭의 path에 추가
            if newValue.count > oldValue.count, let lastDestination = newValue.last {
                switch selectedTab {
                case .map:
                    mapPath.append(lastDestination)
                case .saved:
                    savedPath.append(lastDestination)
                case .profile:
                    profilePath.append(lastDestination)
                }
                // navigationRouter는 동기화용이므로 비움
                navigationRouter.destination = []
            }
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
            PointSearchResultView(latitude: latitude, longitude: longitude, navigationRouter: navigationRouter)
            
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
