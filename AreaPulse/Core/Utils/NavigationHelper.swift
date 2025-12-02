//
//  NavigationHelper.swift
//  AreaPulse
//
//  Created by 바견규 on 12/2/25.
//

import SwiftUI

enum MapApp: String, CaseIterable, Identifiable {
    case kakao = "카카오맵"
    case naver = "네이버지도"
    
    var id: String { rawValue }
}

struct NavigationHelper {
    
    /// 길찾기 열기
    static func openNavigation(
        to destination: (lat: Double, lng: Double, name: String),
        from origin: (lat: Double, lng: Double)? = nil,
        app: MapApp
    ) {
        var urlString: String
        
        switch app {
        case .kakao:
            if let origin = origin {
                urlString = "kakaomap://route?sp=\(origin.lat),\(origin.lng)&ep=\(destination.lat),\(destination.lng)&by=PUBLICTRANSIT"
            } else {
                urlString = "kakaomap://route?ep=\(destination.lat),\(destination.lng)&by=PUBLICTRANSIT"
            }
            
        case .naver:
            let encodedName = destination.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            if let origin = origin {
                urlString = "nmap://route/public?slat=\(origin.lat)&slng=\(origin.lng)&dlat=\(destination.lat)&dlng=\(destination.lng)&dname=\(encodedName)&appname=io.tuist.AreaPulse"
            } else {
                urlString = "nmap://route/public?dlat=\(destination.lat)&dlng=\(destination.lng)&dname=\(encodedName)&appname=io.tuist.AreaPulse"
            }
        }
        
        guard let url = URL(string: urlString) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        } else {
            openAppStore(for: app)
        }
    }
    
    /// 앱 설치 여부 확인
    static func isAppInstalled(_ app: MapApp) -> Bool {
        let scheme = app == .kakao ? "kakaomap://" : "nmap://"
        guard let url = URL(string: scheme) else { return false }
        return UIApplication.shared.canOpenURL(url)
    }
    
    /// 사용 가능한 지도 앱 목록
    static var availableApps: [MapApp] {
        MapApp.allCases.filter { isAppInstalled($0) }
    }
    
    private static func openAppStore(for app: MapApp) {
        let appStoreId = app == .kakao ? "304608425" : "311867728"
        if let url = URL(string: "itms-apps://itunes.apple.com/app/id\(appStoreId)") {
            UIApplication.shared.open(url)
        }
    }
}
