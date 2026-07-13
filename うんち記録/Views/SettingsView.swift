//
//  SettingsView.swift
//  うんち記録
//
//  設定画面
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppLockManager.self) private var appLock
    @Environment(BowelConditionColorSettings.self) private var conditionColors
    @State private var showSetPIN = false
    @State private var showDisableConfirm = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("お通じアイコンの色") {
                    ForEach(BowelCondition.allCases, id: \.self) { condition in
                        NavigationLink {
                            ConditionColorPickerView(condition: condition)
                        } label: {
                            HStack(spacing: 12) {
                                ConditionIconView(condition: condition, size: 32)
                                    .frame(width: 40, alignment: .center)
                                Text(condition.displayName)
                                    .foregroundStyle(AppColors.textPrimary)
                                Spacer()
                                Circle()
                                    .fill(conditionColors.color(for: condition))
                                    .frame(width: 22, height: 22)
                                    .overlay(
                                        Circle()
                                            .stroke(AppColors.border, lineWidth: 1)
                                    )
                            }
                        }
                    }
                }
                .listRowBackground(AppColors.background)
                
                Section("セキュリティ") {
                    Toggle("パスワード", isOn: Binding(
                        get: { appLock.isLockEnabled },
                        set: { newValue in
                            if newValue {
                                AppAnalytics.log(.settings_lock_toggle_on)
                                showSetPIN = true
                            } else {
                                showDisableConfirm = true
                            }
                        }
                    ))
                }
                .listRowBackground(AppColors.background)
            }
            .scrollContentBackground(.hidden)
            .background(AppColors.background)
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSetPIN) {
                SetPINView()
            }
            .confirmationDialog("パスワード保護をオフにしますか？", isPresented: $showDisableConfirm, titleVisibility: .visible) {
                Button("オフにする", role: .destructive) {
                    AppAnalytics.log(.settings_lock_toggle_off_execute)
                    appLock.disableLock()
                }
                Button("キャンセル", role: .cancel) {
                    AppAnalytics.log(.settings_lock_toggle_off_cancel)
                }
            } message: {
                Text("ロック画面は表示されなくなります。")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppLockManager.shared)
        .environment(BowelConditionColorSettings.shared)
}
