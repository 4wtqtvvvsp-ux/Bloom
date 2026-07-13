//
//  MedicationItem.swift
//  うんち記録
//
//  薬の記録
//

import Foundation
import SwiftUI

struct MedicationItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var startDate: Date?
    var colorIndex: Int  // カレンダー表示用の色インデックス
    
    init(id: UUID = UUID(), name: String, startDate: Date? = nil, colorIndex: Int = 0) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.colorIndex = colorIndex
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decodeIfPresent(Date.self, forKey: .startDate)
        colorIndex = try container.decodeIfPresent(Int.self, forKey: .colorIndex) ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, startDate, colorIndex
    }
    
    var calendarColor: Color {
        let index = colorIndex % AppColors.medicationColors.count
        return AppColors.medicationColors[index]
    }
}
