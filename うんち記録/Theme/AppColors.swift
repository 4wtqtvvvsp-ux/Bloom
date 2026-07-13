//
//  AppColors.swift
//  うんち記録
//
//  生理記録アプリ風のパステルカラーパレット
//

import SwiftUI

enum AppColors {
    // メインカラー
    static let background = Color.white
    static let pastelPink = Color(red: 1.0, green: 0.85, blue: 0.9)      // #FFD9E6
    static let pastelBlue = Color(red: 0.85, green: 0.95, blue: 1.0)     // #D9F2FF
    static let pastelPinkDark = Color(red: 0.95, green: 0.7, blue: 0.8)   // ボタン用
    static let pastelBlueLight = Color(red: 0.9, green: 0.96, blue: 1.0)  // ヒント背景
    
    // テキスト
    static let textPrimary = Color(red: 0.2, green: 0.2, blue: 0.25)
    static let textSecondary = Color(red: 0.5, green: 0.5, blue: 0.55)
    static let textMuted = Color(red: 0.65, green: 0.65, blue: 0.7)
    
    // アイコン（カスタムアイコンに合わせた色）
    static let iconColor = Color(red: 74/255, green: 75/255, blue: 76/255)  // #4a4b4c
    
    // アクセント
    static let accentPink = Color(red: 0.95, green: 0.55, blue: 0.7)
    static let accentBlue = Color(red: 0.5, green: 0.75, blue: 0.95)
    
    // 日付バー
    static let dateBarBackground = Color(red: 0.98, green: 0.8, blue: 0.85)
    static let dateBarSelected = Color.white
    
    // ボーダー
    static let border = Color(red: 0.9, green: 0.9, blue: 0.92)
    
    // カレンダー用・薬の色（凡例の丸）
    static let medicationColors: [Color] = [
        Color(red: 0.4, green: 0.8, blue: 0.95),   // シアン
        Color(red: 0.4, green: 0.75, blue: 0.5),   // グリーン
        Color(red: 0.95, green: 0.7, blue: 0.4),   // オレンジ
        Color(red: 0.75, green: 0.5, blue: 0.9),   // パープル
        Color(red: 0.95, green: 0.6, blue: 0.6),   // コーラル
    ]
}
