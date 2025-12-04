// NavigationRouter.swift
import Foundation

/// 화면 이동을 제어하기 위한 라우팅 프로토콜
protocol NavigationRoutable {
    var destination: [NavigationDestination] { get set }
    func push(to view: NavigationDestination)
    func pop()
    func popToRootView()
}

@Observable
class NavigationRouter: NavigationRoutable {
    
    var destination: [NavigationDestination] = []
    var popTrigger: Bool = false
    var popToRootTrigger: Bool = false
    
    func push(to view: NavigationDestination) {
        destination.append(view)
    }
    
    func pop() {
        popTrigger.toggle()
    }
    
    func popToRootView() {
        popToRootTrigger.toggle()
    }
}
