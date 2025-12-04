// MainTabView.swift
import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .map
    @Bindable var navigationRouter: NavigationRouter
    
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
            // Push 처리
            if newValue.count > oldValue.count, let lastDestination = newValue.last {
                switch selectedTab {
                case .map:
                    mapPath.append(lastDestination)
                case .saved:
                    savedPath.append(lastDestination)
                case .profile:
                    profilePath.append(lastDestination)
                }
                navigationRouter.destination = []
            }
        }
        .onChange(of: navigationRouter.popTrigger) { _, _ in
            // Pop 처리
            switch selectedTab {
            case .map:
                _ = mapPath.popLast()
            case .saved:
                _ = savedPath.popLast()
            case .profile:
                _ = profilePath.popLast()
            }
        }
        .onChange(of: navigationRouter.popToRootTrigger) { _, _ in
            // Pop to root 처리
            switch selectedTab {
            case .map:
                mapPath.removeAll()
            case .saved:
                savedPath.removeAll()
            case .profile:
                profilePath.removeAll()
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
            BuildingDetailView(buildingId: saveId, navigationRouter: navigationRouter)
            
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
