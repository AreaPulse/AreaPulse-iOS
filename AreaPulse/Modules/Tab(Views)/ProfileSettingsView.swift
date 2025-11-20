//
//  SettingsView.swift
//  AreaPulse
//
//  Created by 바견규 on 11/20/25.
//

import SwiftUI

/// 설정 화면
struct SettingsView: View {
    @State private var notificationsEnabled = true
    @State private var darkModeEnabled = false
    
    var body: some View {
        List {
            Section("알림") {
                Toggle("푸시 알림", isOn: $notificationsEnabled)
            }
            
            Section("화면 설정") {
                Toggle("다크 모드", isOn: $darkModeEnabled)
            }
            
            Section("정보") {
                HStack {
                    Text("버전")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
                
                NavigationLink("개인정보 처리방침") {
                    Text("개인정보 처리방침 내용")
                }
                
                NavigationLink("서비스 이용약관") {
                    Text("서비스 이용약관 내용")
                }
            }
            
            Section {
                Button("계정 삭제") {
                    // 계정 삭제 로직
                }
                .foregroundStyle(.red)
            }
        }
        .navigationTitle("설정")
    }
}

#Preview {
    NavigationStack {
        SettingsView()
    }
}
