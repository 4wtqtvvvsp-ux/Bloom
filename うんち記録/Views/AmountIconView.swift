//
//  AmountIconView.swift
//  うんち記録
//
//  量の SF Symbol 表示
//

import SwiftUI

struct AmountIconView: View {
    let amount: BowelAmount
    var size: CGFloat = 24
    
    var body: some View {
        Image(systemName: amount.systemImageName)
            .font(.system(size: size))
            .foregroundStyle(AppColors.iconColor)
    }
}
