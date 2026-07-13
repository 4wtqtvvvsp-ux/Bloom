//
//  MedicationLog.swift
//  うんち記録
//
//  日別の薬服用記録
//

import Foundation

struct MedicationLog: Identifiable, Codable {
    let id: UUID
    let date: Date
    let medicationId: UUID
    
    init(id: UUID = UUID(), date: Date, medicationId: UUID) {
        self.id = id
        self.date = date
        self.medicationId = medicationId
    }
}
