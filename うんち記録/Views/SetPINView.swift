//
//  SetPINView.swift
//  うんち記録
//
//  4桁パスワードの新規設定（2回入力）
//

import SwiftUI

struct SetPINView: View {
    @Environment(AppLockManager.self) private var appLock
    @Environment(\.dismiss) private var dismiss
    
    @State private var step = 0
    @State private var firstPIN = ""
    @State private var pinInput = ""
    @FocusState private var focusedField: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 28) {
                Text(step == 0 ? "4桁のパスワードを入力" : "もう一度入力してください")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 24)
                
                SecureField("", text: $pinInput)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .font(.title2.monospacedDigit())
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(AppColors.pastelBlueLight)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .focused($focusedField)
                    .onChange(of: pinInput) { _, newValue in
                        pinInput = String(newValue.filter(\.isNumber).prefix(4))
                    }
                
                if step == 1, pinInput.count == 4, pinInput != firstPIN {
                    Text("最初の入力と一致しません")
                        .font(.caption)
                        .foregroundStyle(.red)
                }
                
                Spacer()
            }
            .padding(.horizontal, 24)
            .background(AppColors.background)
            .navigationTitle("パスワードを設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        AppAnalytics.log(.pin_setup_cancel)
                        dismiss()
                    }
                    .foregroundStyle(AppColors.accentPink)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(step == 0 ? "次へ" : "完了") {
                        proceed()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(canProceed ? AppColors.accentPink : AppColors.textMuted)
                    .disabled(!canProceed)
                }
            }
            .onAppear {
                focusedField = true
            }
            .onChange(of: step) { _, _ in
                pinInput = ""
                focusedField = true
            }
        }
    }
    
    private var canProceed: Bool {
        guard pinInput.count == 4 else { return false }
        if step == 1 { return pinInput == firstPIN }
        return true
    }
    
    private func proceed() {
        guard pinInput.count == 4 else { return }
        if step == 0 {
            AppAnalytics.log(.pin_setup_proceed_step1)
            firstPIN = pinInput
            step = 1
        } else if pinInput == firstPIN {
            AppAnalytics.log(.pin_setup_complete)
            appLock.savePINAndEnable(pinInput)
            dismiss()
        }
    }
}

#Preview {
    SetPINView()
        .environment(AppLockManager.shared)
}
