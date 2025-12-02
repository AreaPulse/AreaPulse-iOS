//
//  ProfileView.swift
//  AreaPulse
//
//  Created by 바견규 on 12/01/24.
//

import SwiftUI
import MapKit

/// 프로필 화면
struct ProfileView: View {
    
    @EnvironmentObject private var authManager: AuthManager
    @StateObject private var viewModel = AuthViewModel()
    
    @State private var showLogoutAlert = false
    @State private var showWorkplaceSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                // 사용자 정보 섹션
                Section {
                    if let user = authManager.currentUser {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(user.nickname.isEmpty ? "사용자" : user.nickname)
                                    .font(.headline)
                                
                                Text(user.email)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.leading, 12)
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                // 직장 정보 섹션
                Section("통근 설정") {
                    if let workplace = authManager.workplaceInfo {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "building.2.fill")
                                    .foregroundColor(.blue)
                                Text("직장 주소")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            Text(workplace.address)
                                .font(.body)
                            
                            Button {
                                showWorkplaceSheet = true
                            } label: {
                                Text("변경하기")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    } else {
                        Button {
                            showWorkplaceSheet = true
                        } label: {
                            HStack {
                                Image(systemName: "building.2")
                                    .foregroundColor(.blue)
                                Text("직장 주소 설정하기")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                
                // 계정 관리 섹션
                Section("계정 관리") {
                    Button {
                        showLogoutAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.left.square")
                                .foregroundColor(.red)
                            Text("로그아웃")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                // 앱 정보 섹션
                Section("앱 정보") {
                    HStack {
                        Text("버전")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Link(destination: URL(string: "https://github.com")!) {
                        HStack {
                            Text("GitHub")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .navigationTitle("프로필")
            .sheet(isPresented: $showWorkplaceSheet) {
                WorkplaceSettingView()
            }
            .alert("로그아웃", isPresented: $showLogoutAlert) {
                Button("취소", role: .cancel) { }
                Button("로그아웃", role: .destructive) {
                    Task {
                        await viewModel.logout()
                    }
                }
            } message: {
                Text("정말 로그아웃하시겠습니까?")
            }
            .overlay {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.black.opacity(0.2))
                }
            }
            .alert("오류", isPresented: $viewModel.showError) {
                Button("확인", role: .cancel) { }
            } message: {
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                }
            }
        }
    }
}

/// 직장 주소 설정 화면
struct WorkplaceSettingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var authManager: AuthManager
    
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var selectedLocation: MKMapItem?
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 검색 바
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("직장 주소를 검색하세요", text: $searchText)
                        .textFieldStyle(.plain)
                        .onSubmit {
                            Task {
                                await searchLocation()
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                            searchResults = []
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                
                if isSearching {
                    ProgressView()
                        .padding()
                }
                
                // 검색 결과
                List(searchResults, id: \.self) { item in
                    Button {
                        selectedLocation = item
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name ?? "알 수 없는 장소")
                                .font(.headline)
                            
                            if let address = item.placemark.title {
                                Text(address)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
                
                // 선택된 위치 표시
                if let selected = selectedLocation {
                    VStack(spacing: 12) {
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("선택한 위치")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text(selected.name ?? "알 수 없는 장소")
                                .font(.headline)
                            
                            if let address = selected.placemark.title {
                                Text(address)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                        
                        Button {
                            saveWorkplace(selected)
                        } label: {
                            Text("저장하기")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .background(Color(.systemBackground))
                }
            }
            .navigationTitle("직장 주소 설정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func searchLocation() async {
        guard !searchText.isEmpty else { return }
        
        isSearching = true
        defer { isSearching = false }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780), // 서울 중심
            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
        )
        
        let search = MKLocalSearch(request: request)
        
        do {
            let response = try await search.start()
            searchResults = response.mapItems
        } catch {
            print("❌ 검색 실패: \(error)")
            searchResults = []
        }
    }
    
    private func saveWorkplace(_ item: MKMapItem) {
        let address = item.placemark.title ?? item.name ?? "알 수 없는 장소"
        let coordinate = item.placemark.coordinate
        
        authManager.setWorkplace(
            address: address,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        dismiss()
    }
}

#Preview {
    ProfileView()
        .environmentObject(AuthManager.shared)
}

