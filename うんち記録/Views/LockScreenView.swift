//
//  LockScreenView.swift
//  うんち記録
//
//  アプリ起動・復帰時のロック解除
//

import SwiftUI

struct LockScreenView: View {
    @Environment(AppLockManager.self) private var appLock
    
    @State private var pinInput = ""
    @State private var showError = false
    @FocusState private var focusedField: Bool
    
    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            
            VStack(spacing: 32) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(AppColors.accentPink)
                
                Text("パスワードを入力")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                
                SecureField("", text: $pinInput)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .font(.title2.monospacedDigit())
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(AppColors.pastelBlueLight)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .frame(maxWidth: 280)
                    .focused($focusedField)
                    .onChange(of: pinInput) { _, newValue in
                        pinInput = String(newValue.filter(\.isNumber).prefix(4))
                        showError = false
                        if pinInput.count == 4 {
                            tryUnlock()
                        }
                    }
                
                if showError {
                    Text("パスワードが違います")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
            }
        }
        .onAppear {
            focusedField = true
        }
    }
    
    private func tryUnlock() {
        guard appLock.verifyPIN(pinInput) else {
            AppAnalytics.log(.lock_unlock_fail)
            showError = true
            pinInput = ""
            focusedField = true
            return
        }
        AppAnalytics.log(.lock_unlock_success)
        appLock.unlock()
    }
}

#Preview {
    LockScreenView()
        .environment(AppLockManager.shared)
}
