//
//  ContentView.swift
//  うんち記録
//
//  Created by Apple on 2026/02/27.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        let appLock = AppLockManager.shared
        ZStack {
            MainTabView()
            if appLock.isLockEnabled && !appLock.isUnlocked {
                LockScreenView()
            }
        }
        .environment(DataStore.shared)
        .environment(appLock)
        .environment(BowelConditionColorSettings.shared)
        .onChange(of: scenePhase) { _, phase in
            if phase == .background {
                if AppLockManager.shared.isLockEnabled {
                    AppAnalytics.log(.app_lock_on_background)
                }
                AppLockManager.shared.lockIfEnabled()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(BowelConditionColorSettings.shared)
}
