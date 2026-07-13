//
//  ConditionIconView.swift
//  うんち記録
//
//  状態に応じたアイコン表示（Assets：とても硬い・硬め・BowelCondition_normal・やわらかめ・下痢）
//  サイズを指定してUI崩れを防ぐ
//

import SwiftUI

struct ConditionIconView: View {
    @Environment(BowelConditionColorSettings.self) private var conditionColors
    
    let condition: BowelCondition
    var size: CGFloat = 40
    
    var body: some View {
        Group {
            if condition.isSystemImage {
                Image(systemName: condition.iconName)
                    .font(.system(size: size))
                    .foregroundStyle(conditionColors.color(for: condition))
            } else if let recolored = conditionColors.lineRecoloredUIImage(for: condition) {
                Image(uiImage: recolored)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: size, height: size)
            } else {
                Image(condition.iconName)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
            }
        }
    }
}
