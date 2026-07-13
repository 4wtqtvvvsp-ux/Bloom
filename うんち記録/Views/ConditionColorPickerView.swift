//
//  ConditionColorPickerView.swift
//  うんち記録
//
//  硬さアイコンの色変更とプレビュー
//

import SwiftUI

struct ConditionColorPickerView: View {
    let condition: BowelCondition
    @Environment(BowelConditionColorSettings.self) private var colorSettings
    @State private var pickerColor: Color
    
    init(condition: BowelCondition) {
        self.condition = condition
        _pickerColor = State(initialValue: BowelConditionColorSettings.shared.color(for: condition))
    }
    
    var body: some View {
        Form {
            Section {
                VStack(alignment: .leading, spacing: 20) {
                    previewCard(
                        title: "カレンダーの日",
                        iconSize: 34,
                        rowBackground: AppColors.pastelBlue.opacity(0.5),
                        usesDayStyle: true
                    )
                    previewCard(
                        title: "お通じを記録（一覧の行）",
                        iconSize: 52,
                        rowBackground: AppColors.pastelBlueLight,
                        usesDayStyle: false
                    )
                }
                .listRowInsets(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 16))
            } header: {
                Text("プレビュー")
            }
            
            Section {
                ColorPicker("アイコンの色", selection: $pickerColor, supportsOpacity: true)
                    .onChange(of: pickerColor) { _, newValue in
                        colorSettings.setColor(newValue, for: condition)
                    }
                Button("この項目をデフォルトに戻す") {
                    AppAnalytics.log(.settings_icon_color_reset, parameters: ["condition": condition.rawValue])
                    colorSettings.resetToDefault(for: condition)
                    pickerColor = colorSettings.color(for: condition)
                }
                .foregroundStyle(AppColors.accentPink)
            } header: {
                Text("色の設定")
            }
        }
        .scrollContentBackground(.hidden)
        .background(AppColors.background)
        .navigationTitle(condition.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            pickerColor = colorSettings.color(for: condition)
            AppAnalytics.log(.screen_condition_icon_color, parameters: ["condition": condition.rawValue])
        }
    }
    
    @ViewBuilder
    private func previewCard(title: String, iconSize: CGFloat, rowBackground: Color, usesDayStyle: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(AppColors.textSecondary)
            if usesDayStyle {
                VStack(spacing: 4) {
                    Text("8")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textPrimary)
                    Group {
                        Circle()
                            .fill(AppColors.accentBlue.opacity(0.6))
                            .frame(width: 7, height: 7)
                    }
                    .frame(height: 10)
                    ConditionIconView(condition: condition, size: iconSize)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(rowBackground)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(AppColors.accentPink.opacity(0.5), lineWidth: 1)
                )
            } else {
                HStack(spacing: 16) {
                    ConditionIconView(condition: condition, size: iconSize)
                        .frame(width: iconSize + 8, alignment: .center)
                    Text(condition.displayName)
                        .font(.body)
                        .foregroundStyle(AppColors.textPrimary)
                    Spacer()
                }
                .padding(16)
                .background(rowBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }
}

#Preview {
    NavigationStack {
        ConditionColorPickerView(condition: .normal)
    }
    .environment(BowelConditionColorSettings.shared)
}
