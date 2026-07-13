//
//  SupplementItem.swift
//  うんち記録
//
//  サプリメントの記録
//

import Foundation

struct SupplementItem: Identifiable, Codable {
    let id: UUID
    var name: String
    var startDate: Date?
    
    init(id: UUID = UUID(), name: String, startDate: Date? = nil) {
        self.id = id
        self.name = name
        self.startDate = startDate
    }
}
