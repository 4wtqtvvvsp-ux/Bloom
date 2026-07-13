//
//  BowelRecord.swift
//  うんち記録
//
//  お通じ記録のデータモデル（直接的な表現は避ける）
//

import Foundation

/// お通じの状態（ブリストルスケールを抽象化）
enum BowelCondition: String, Codable, CaseIterable {
    case veryHard = "very_hard"   // とても硬め
    case hard = "hard"            // 硬め
    case normal = "normal"        // ちょうど良い
    case soft = "soft"            // やわらかめ
    case verySoft = "very_soft"   // 下痢
    
    var displayName: String {
        switch self {
        case .veryHard: return "とても硬め"
        case .hard: return "硬め"
        case .normal: return "ちょうどいい"
        case .soft: return "やわらかめ"
        case .verySoft: return "下痢"
        }
    }
    
    /// 星の数で表現（1〜5）
    var starCount: Int {
        switch self {
        case .veryHard: return 1
        case .hard: return 2
        case .normal: return 3
        case .soft: return 4
        case .verySoft: return 5
        }
    }
    
    /// 調子アイコン（「ちょうどいい」は BowelCondition_normal でアセット参照）
    var iconName: String {
        switch self {
        case .veryHard: return "とても硬い"
        case .hard: return "硬め"
        case .normal: return "BowelCondition_normal"
        case .soft: return "やわらかめ"
        case .verySoft: return "下痢"
        }
    }
    
    /// すべてアセット画像（1080×1080 など）
    var isSystemImage: Bool { false }
}

/// お通じの量（5段）
enum BowelAmount: String, Codable, CaseIterable {
    case veryLittle = "very_little"   // とても少ない
    case little = "little"            // 少ない
    case medium = "medium"            // ちょうどいい
    case much = "much"                // 多い
    case veryMuch = "very_much"      // とても多い
    
    var displayName: String {
        switch self {
        case .veryLittle: return "とても少ない"
        case .little: return "少ない"
        case .medium: return "ちょうどいい"
        case .much: return "多い"
        case .veryMuch: return "とても多い"
        }
    }
    
    /// SF Symbol（量のイメージ）
    var systemImageName: String {
        switch self {
        case .veryLittle: return "arrow.down.circle"
        case .little: return "minus.circle"
        case .medium: return "equal.circle"
        case .much: return "plus.circle"
        case .veryMuch: return "arrow.up.circle"
        }
    }
}

/// 1回のお通じ記録
struct BowelRecord: Identifiable, Codable {
    let id: UUID
    let date: Date
    let condition: BowelCondition
    let amount: BowelAmount
    let note: String?
    var imageIds: [String]  // 記録に添付した画像のファイル名
    
    init(id: UUID = UUID(), date: Date = Date(), condition: BowelCondition, amount: BowelAmount = .medium, note: String? = nil, imageIds: [String] = []) {
        self.id = id
        self.date = date
        self.condition = condition
        self.amount = amount
        self.note = note
        self.imageIds = imageIds
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        date = try container.decode(Date.self, forKey: .date)
        condition = try container.decode(BowelCondition.self, forKey: .condition)
        amount = try container.decodeIfPresent(BowelAmount.self, forKey: .amount) ?? .medium
        note = try container.decodeIfPresent(String.self, forKey: .note)
        imageIds = try container.decodeIfPresent([String].self, forKey: .imageIds) ?? []
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(date, forKey: .date)
        try container.encode(condition, forKey: .condition)
        try container.encode(amount, forKey: .amount)
        try container.encodeIfPresent(note, forKey: .note)
        try container.encode(imageIds, forKey: .imageIds)
    }
    
    enum CodingKeys: String, CodingKey {
        case id, date, condition, amount, note, imageIds
    }
}
