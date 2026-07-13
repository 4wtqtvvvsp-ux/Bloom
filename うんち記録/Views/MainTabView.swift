//
//  MainTabView.swift
//  うんち記録
//
//  ボトムナビゲーション（参考画像風）
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("ホーム")
                }
                .tag(0)
            
            CalendarView()
                .tabItem {
                    Image(systemName: "calendar")
                    Text("カレンダー")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("設定")
                }
                .tag(2)
        }
        .tint(AppColors.accentPink)
        .onChange(of: selectedTab) { _, newValue in
            switch newValue {
            case 0: AppAnalytics.log(.tab_home)
            case 1: AppAnalytics.log(.tab_calendar)
            case 2: AppAnalytics.log(.tab_settings)
            default: break
            }
        }
    }
}

#Preview {
    MainTabView()
        .environment(DataStore.shared)
        .environment(AppLockManager.shared)
        .environment(BowelConditionColorSettings.shared)
}
