//
//  NavigationDestination.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation

enum NavigationDestination: Equatable, Hashable {
    case contentView
    
    // MARK: - Map Tab
    case map
    case buildingDetail(buildingId: Int)
    case pointSearchResult(latitude: Double, longitude: Double)
    case reviewWrite(buildingId: Int)
    case reviewList(buildingId: Int)
    
    // MARK: - Saved Tab
    case savedBuildings
    case savedBuildingDetail(saveId: Int)
    
    // MARK: - Profile Tab
    case profile
    case settings
}
