//
//  SavedBuildingsView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 찜한 건물 목록 화면
struct SavedBuildingsView: View {
    @State private var viewModel: SavedBuildingsViewModel
    
    init(navigationRouter: NavigationRouter) {
        _viewModel = State(initialValue: SavedBuildingsViewModel(navigationRouter: navigationRouter))
    }
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.savedBuildings.isEmpty {
                emptyStateView
            } else {
                savedBuildingsList
            }
        }
        .navigationTitle("찜한 건물")
        .task {
            await viewModel.loadSavedBuildings()
        }
        .refreshable {
            await viewModel.loadSavedBuildings()
        }
        .alert("오류", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("확인") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "heart.slash")
                .font(.system(size: 60))
                .foregroundStyle(.gray)
            
            Text("찜한 건물이 없습니다")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("관심 있는 건물을 찜해보세요")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var savedBuildingsList: some View {
        List {
            ForEach(viewModel.savedBuildings) { saved in
                Button {
                    viewModel.navigateToBuildingDetail(buildingId: saved.buildingId)
                } label: {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(saved.building.buildingName ?? "이름 없음")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Text(saved.building.address ?? "주소 없음")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(1)
                                
                                HStack(spacing: 8) {
                                    Text(saved.building.buildingType.displayName)
                                        .font(.caption2)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 4)
                                        .background(Capsule().fill(Color.blue.opacity(0.2)))
                                    
                                    if let buildYear = saved.building.buildYear {
                                        Text("\(buildYear)년")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        if let memo = saved.memo {
                            Text(memo)
                                .font(.subheadline)
                                .foregroundStyle(.blue)
                                .padding(.vertical, 4)
                                .padding(.horizontal, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 6)
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .lineLimit(2)
                        }
                        
                        HStack {
                            Image(systemName: "clock")
                                .font(.caption2)
                            Text(saved.createdAt, style: .date)
                                .font(.caption2)
                        }
                        .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                    Button(role: .destructive) {
                        Task {
                            await viewModel.deleteSavedBuilding(saved)
                        }
                    } label: {
                        Label("삭제", systemImage: "trash")
                    }
                }
            }
        }
        .listStyle(.plain)
    }
}

#Preview {
    NavigationStack {
        SavedBuildingsView(navigationRouter: NavigationRouter())
    }
}
