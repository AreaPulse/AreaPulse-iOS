//
//  ProfileView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 프로필 화면
struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(.gray)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("사용자")
                                .font(.headline)
                            
                            Text("user@example.com")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.leading, 8)
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    NavigationLink {
                        SavedBuildingsView(navigationRouter: NavigationRouter())
                    } label: {
                        Label("찜한 건물", systemImage: "heart")
                    }
                    
                    NavigationLink {
                        Text("내 리뷰")
                    } label: {
                        Label("내 리뷰", systemImage: "text.bubble")
                    }
                }
                
                Section {
                    NavigationLink {
                        SettingsView()
                    } label: {
                        Label("설정", systemImage: "gearshape")
                    }
                    
                    Button {
                        // 로그아웃 로직
                    } label: {
                        Label("로그아웃", systemImage: "arrow.right.square")
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("프로필")
        }
    }
}

#Preview {
    ProfileView()
}
