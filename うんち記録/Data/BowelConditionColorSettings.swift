//
//  BowelConditionColorSettings.swift
//  うんち記録
//
//  お通じの硬さアイコン色（設定から変更・永続化）
//

import SwiftUI
import UIKit

private struct RGBA: Codable, Equatable {
    var r, g, b, a: Double
}

@Observable
final class BowelConditionColorSettings {
    static let shared = BowelConditionColorSettings()
    
    private let defaultsKey = "bowel_condition_icon_colors_v1"
    private var rgbaByCondition: [String: RGBA] = [:]
    /// 色変更時にビュー更新を確実にするためのトークン
    private(set) var changeToken = 0
    private let lineRecolorCache = NSCache<NSString, UIImage>()
    
    private init() {
        load()
    }
    
    func color(for condition: BowelCondition) -> Color {
        _ = changeToken
        if let rgba = rgbaByCondition[condition.rawValue] {
            return Color(red: rgba.r, green: rgba.g, blue: rgba.b, opacity: rgba.a)
        }
        return Self.defaultColor(for: condition)
    }
    
    func lineRecoloredUIImage(for condition: BowelCondition) -> UIImage? {
        _ = changeToken
        guard let rgba = effectiveRGBA(for: condition) else { return nil }
        let key = cacheKey(conditionRaw: condition.rawValue, rgba: rgba)
        if let hit = lineRecolorCache.object(forKey: key) { return hit }
        guard let base = UIImage(named: condition.iconName) else { return nil }
        let ui = UIColor(color(for: condition))
        guard let out = ConditionIconImageProcessor.imageReplacingLineColor(base, with: ui) else { return nil }
        lineRecolorCache.setObject(out, forKey: key)
        return out
    }
    
    func setColor(_ color: Color, for condition: BowelCondition) {
        guard let rgba = color.rgbaForStorage else { return }
        rgbaByCondition[condition.rawValue] = rgba
        changeToken &+= 1
        lineRecolorCache.removeAllObjects()
        save()
    }
    
    func resetToDefault(for condition: BowelCondition) {
        rgbaByCondition.removeValue(forKey: condition.rawValue)
        changeToken &+= 1
        lineRecolorCache.removeAllObjects()
        save()
    }
    
    static func defaultColor(for condition: BowelCondition) -> Color {
        switch condition {
        case .veryHard:
            return Color(red: 176 / 255, green: 104 / 255, blue: 78 / 255)
        case .hard:
            return Color(red: 198 / 255, green: 136 / 255, blue: 82 / 255)
        case .normal:
            return Color(red: 121 / 255, green: 163 / 255, blue: 95 / 255)
        case .soft:
            return Color(red: 94 / 255, green: 157 / 255, blue: 171 / 255)
        case .verySoft:
            return Color(red: 114 / 255, green: 126 / 255, blue: 196 / 255)
        }
    }
    
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: defaultsKey),
              let decoded = try? JSONDecoder().decode([String: RGBA].self, from: data) else { return }
        rgbaByCondition = decoded
    }
    
    private func save() {
        guard let data = try? JSONEncoder().encode(rgbaByCondition) else { return }
        UserDefaults.standard.set(data, forKey: defaultsKey)
    }
    
    private func cacheKey(conditionRaw: String, rgba: RGBA) -> NSString {
        NSString(string: "\(conditionRaw)_\(rgba.r)_\(rgba.g)_\(rgba.b)_\(rgba.a)")
    }
    
    private func effectiveRGBA(for condition: BowelCondition) -> RGBA? {
        if let saved = rgbaByCondition[condition.rawValue] {
            return saved
        }
        return Self.defaultColor(for: condition).rgbaForStorage
    }
}

private extension Color {
    var rgbaForStorage: RGBA? {
        let ui = UIColor(self)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if ui.getRed(&r, green: &g, blue: &b, alpha: &a) {
            return RGBA(r: Double(r), g: Double(g), b: Double(b), a: Double(a))
        }
        var w: CGFloat = 0
        if ui.getWhite(&w, alpha: &a) {
            let d = Double(w)
            return RGBA(r: d, g: d, b: d, a: Double(a))
        }
        return nil
    }
}
