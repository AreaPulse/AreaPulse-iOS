//
//  SavedBuildingsViewModel.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import Foundation
import Observation

@Observable
class SavedBuildingsViewModel {
    
    // MARK: - Properties
    
    var savedBuildings: [SavedBuildingDetail] = []
    var isLoading: Bool = false
    var errorMessage: String?
    
    private let apiService: AreaPulseAPIService
    private let navigationRouter: NavigationRouter
    
    // MARK: - Initialization
    
    init(
        apiService: AreaPulseAPIService = AreaPulseAPIService(),
        navigationRouter: NavigationRouter
    ) {
        self.apiService = apiService
        self.navigationRouter = navigationRouter
    }
    
    // MARK: - Actions
    
    /// 찜한 건물 목록 로드
    @MainActor
    func loadSavedBuildings() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await apiService.getSavedBuildings()
            savedBuildings = response.savedBuildings
        } catch {
            errorMessage = error.localizedDescription
            print("Error loading saved buildings: \(error)")
        }
        
        isLoading = false
    }
    
    /// 찜 삭제
    @MainActor
    func deleteSavedBuilding(_ saved: SavedBuildingDetail) async {
        do {
            let response = try await apiService.deleteSavedBuilding(saveId: saved.id)
            if response.success {
                savedBuildings.removeAll { $0.id == saved.id }
            }
        } catch {
            errorMessage = error.localizedDescription
            print("Error deleting saved building: \(error)")
        }
    }
    
    /// 건물 상세 화면으로 이동
    func navigateToBuildingDetail(buildingId: Int) {
        navigationRouter.push(to: .buildingDetail(buildingId: buildingId))
    }
}
