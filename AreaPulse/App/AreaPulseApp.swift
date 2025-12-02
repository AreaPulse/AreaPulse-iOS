import SwiftUI

@main
struct AreaPulseApp: App {
    
    @StateObject private var authManager = AuthManager.shared
    @StateObject private var container = DIContainer()
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                MainTabView(navigationRouter: container.navigationRouter)
                    .environmentObject(authManager)
                    .environmentObject(container)
            } else {
                LoginView()
                    .environmentObject(authManager)
            }
        }
    }
}
