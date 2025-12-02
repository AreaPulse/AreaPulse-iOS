//
//  NearByInfoModal.swift
//  AreaPulse
//
//  Created by 바견규 on 12/1/25.
//

import SwiftUI
import CoreLocation

// MARK: - Nearby Info Modal View

struct NearbyInfoModalView: View {
    @Bindable var viewModel: MapViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var modalSearchText: String = ""
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 모달 내부 검색바
                modalSearchBar
                
                // 탭 선택
                Picker("", selection: $viewModel.selectedTab) {
                    Text("인프라").tag(MapViewModel.NearbyTab.infrastructure)
                    Text("건물").tag(MapViewModel.NearbyTab.buildings)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // 컨텐츠
                ScrollView {
                    VStack(spacing: 12) {
                        if viewModel.selectedTab == .infrastructure {
                            infrastructureContent
                        } else {
                            buildingsContent
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("주변 정보")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        viewModel.navigateToPointSearchResult()
                        dismiss()
                    } label: {
                        HStack(spacing: 4) {
                            Text("상세")
                            Image(systemName: "arrow.right.circle.fill")
                        }
                        .font(.subheadline)
                    }
                }
            }
        }
    }
    
    // MARK: - Modal Search Bar
    
    private var modalSearchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                
                TextField("주변 정보 검색", text: $modalSearchText)
                    .autocorrectionDisabled()
                
                if !modalSearchText.isEmpty {
                    Button {
                        modalSearchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    // MARK: - Search Filtered Data
    
    private var filteredInfrastructure: [Infrastructure] {
        let text = modalSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return viewModel.filteredInfrastructure }
        
        return viewModel.filteredInfrastructure.filter { infra in
            infra.name.localizedCaseInsensitiveContains(text) ||
            infra.category.displayName.localizedCaseInsensitiveContains(text) ||
            (infra.address ?? "").localizedCaseInsensitiveContains(text)
        }
    }
    
    private var filteredBuildings: [Building] {
        let text = modalSearchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { return viewModel.nearbyBuildings }
        
        return viewModel.nearbyBuildings.filter { building in
            (building.buildingName ?? "").localizedCaseInsensitiveContains(text) ||
            (building.address ?? "").localizedCaseInsensitiveContains(text) ||
            building.buildingType.displayName.localizedCaseInsensitiveContains(text)
        }
    }
    
    // MARK: - Infrastructure Content
    
    private var infrastructureContent: some View {
        VStack(spacing: 16) {
            // 카테고리별 그룹화 (병원, 마트 제외)
            let infraByCategory = Dictionary(grouping: filteredInfrastructure) { $0.category }
                .filter { $0.key != .hospital && $0.key != .mart }
            
            if infraByCategory.isEmpty {
                emptyStateView(message: "검색 결과가 없습니다")
            } else {
                ForEach(Array(infraByCategory.keys.sorted(by: { $0.displayName < $1.displayName })), id: \.self) { category in
                    if let items = infraByCategory[category] {
                        VStack(alignment: .leading, spacing: 8) {
                            // 카테고리 헤더
                            HStack {
                                Image(systemName: category.iconName)
                                    .foregroundStyle(.blue)
                                Text(category.displayName)
                                    .font(.headline)
                                Spacer()
                                Text("\(items.count)")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.secondarySystemBackground))
                            )
                            
                            // 인프라 목록
                            ForEach(items) { infra in
                                InfrastructureRowView(
                                    infrastructure: infra,
                                    referenceCoordinate: viewModel.selectedLocation
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Buildings Content
    
    private var buildingsContent: some View {
        VStack(spacing: 12) {
            if filteredBuildings.isEmpty {
                emptyStateView(message: "검색 결과가 없습니다")
            } else {
                ForEach(filteredBuildings) { building in
                    Button {
                        viewModel.selectBuilding(building)
                        dismiss()
                    } label: {
                        BuildingRowView(
                            building: building,
                            referenceCoordinate: viewModel.selectedLocation
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // 환경 정보
            if !viewModel.environmentData.isEmpty && modalSearchText.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("환경 정보")
                        .font(.headline)
                        .fontWeight(.bold)
                    
                    ForEach(viewModel.environmentData) { data in
                        EnvironmentDataCardView(data: data)
                    }
                }
                .padding(.top, 8)
            }
        }
    }
    
    // MARK: - Empty State
    
    private func emptyStateView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            
            Text(message)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

