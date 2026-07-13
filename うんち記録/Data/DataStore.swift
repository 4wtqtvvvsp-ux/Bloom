//
//  DataStore.swift
//  うんち記録
//
//  記録の永続化
//

import Foundation
import SwiftUI

@Observable
final class DataStore {
    static let shared = DataStore()
    
    var records: [BowelRecord] = [] {
        didSet { saveRecords() }
    }
    
    var medications: [MedicationItem] = [] {
        didSet { saveMedications() }
    }
    
    var medicationLogs: [MedicationLog] = [] {
        didSet { saveMedicationLogs() }
    }
    
    /// 服用終了した薬（ログの表示用。カレンダー上の丸はこの情報で解決する）
    var archivedMedications: [MedicationItem] = [] {
        didSet { saveArchivedMedications() }
    }
    
    private let recordsKey = "bowel_records"
    private let medicationsKey = "medications"
    private let medicationLogsKey = "medication_logs"
    private let archivedMedicationsKey = "archived_medications"
    private let migrationKey = "supplement_medication_merged"
    
    private init() {
        load()
    }
    
    private func load() {
        if let data = UserDefaults.standard.data(forKey: recordsKey),
           let decoded = try? JSONDecoder().decode([BowelRecord].self, from: data) {
            records = decoded
        }
        if let data = UserDefaults.standard.data(forKey: medicationsKey),
           let decoded = try? JSONDecoder().decode([MedicationItem].self, from: data) {
            medications = decoded
        }
        if let data = UserDefaults.standard.data(forKey: medicationLogsKey),
           let decoded = try? JSONDecoder().decode([MedicationLog].self, from: data) {
            medicationLogs = decoded
        }
        if let data = UserDefaults.standard.data(forKey: archivedMedicationsKey),
           let decoded = try? JSONDecoder().decode([MedicationItem].self, from: data) {
            archivedMedications = decoded
        }
        // サプリを薬に統合（マイグレーション）
        if !UserDefaults.standard.bool(forKey: migrationKey) {
            if let data = UserDefaults.standard.data(forKey: "supplements"),
               let supplements = try? JSONDecoder().decode([SupplementItem].self, from: data) {
                for (index, item) in supplements.enumerated() {
                    medications.append(MedicationItem(name: item.name, startDate: item.startDate, colorIndex: index))
                }
                UserDefaults.standard.removeObject(forKey: "supplements")
            }
            UserDefaults.standard.set(true, forKey: migrationKey)
        }
    }
    
    private func saveRecords() {
        guard let data = try? JSONEncoder().encode(records) else { return }
        UserDefaults.standard.set(data, forKey: recordsKey)
    }
    
    private func saveMedications() {
        guard let data = try? JSONEncoder().encode(medications) else { return }
        UserDefaults.standard.set(data, forKey: medicationsKey)
    }
    
    private func saveMedicationLogs() {
        guard let data = try? JSONEncoder().encode(medicationLogs) else { return }
        UserDefaults.standard.set(data, forKey: medicationLogsKey)
    }
    
    private func saveArchivedMedications() {
        guard let data = try? JSONEncoder().encode(archivedMedications) else { return }
        UserDefaults.standard.set(data, forKey: archivedMedicationsKey)
    }
    
    /// ログの medicationId から薬を解決（服用中 or アーカイブ）
    func medication(for id: UUID) -> MedicationItem? {
        medications.first { $0.id == id } ?? archivedMedications.first { $0.id == id }
    }
    
    /// 服用をやめる：一覧から外すが、日別ログは残す
    func stopTakingMedication(_ item: MedicationItem) {
        guard let idx = medications.firstIndex(where: { $0.id == item.id }) else { return }
        let removed = medications.remove(at: idx)
        if !archivedMedications.contains(where: { $0.id == removed.id }) {
            archivedMedications.append(removed)
        }
    }
    
    func add(_ record: BowelRecord) {
        records.append(record)
    }
    
    func delete(_ record: BowelRecord) {
        ImageStore.deleteAll(ids: record.imageIds)
        records.removeAll { $0.id == record.id }
    }
    
    func update(_ record: BowelRecord, condition: BowelCondition, amount: BowelAmount, note: String?, imageIds: [String]? = nil) {
        guard let index = records.firstIndex(where: { $0.id == record.id }) else { return }
        let newImageIds = imageIds ?? record.imageIds
        // 削除された画像をストレージから削除
        let removedIds = Set(record.imageIds).subtracting(newImageIds)
        ImageStore.deleteAll(ids: Array(removedIds))
        let updated = BowelRecord(
            id: record.id,
            date: record.date,
            condition: condition,
            amount: amount,
            note: note,
            imageIds: newImageIds
        )
        records[index] = updated
    }
    
    func records(for date: Date) -> [BowelRecord] {
        let calendar = Calendar.current
        return records.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func hasRecord(on date: Date) -> Bool {
        !records(for: date).isEmpty
    }
    
    /// 指定月の排便率（記録ありの日数 / 対象日数 × 100、小数第1位まで）
    /// 今月の場合：1日〜今日までで計算（未来は含めない）
    /// 先月以前：月全体で計算
    func bowelMovementRate(for month: Date) -> Double {
        let calendar = Calendar.current
        let today = Date()
        
        guard let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: month)) else {
            return 0.0
        }
        
        let totalDays: Int
        let dayRange: ClosedRange<Int>
        
        if calendar.isDate(month, equalTo: today, toGranularity: .month) {
            // 今月：1日〜今日まで
            let todayDay = calendar.component(.day, from: today)
            totalDays = todayDay
            dayRange = 1...todayDay
        } else if month > today {
            // 未来の月：計算対象なし
            return 0.0
        } else {
            // 先月以前：月全体
            guard let range = calendar.range(of: .day, in: .month, for: month) else { return 0.0 }
            totalDays = range.count
            dayRange = range.lowerBound...range.upperBound - 1
        }
        
        guard totalDays > 0 else { return 0.0 }
        
        var daysWithRecord = 0
        for day in dayRange {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: firstDay),
               hasRecord(on: date) {
                daysWithRecord += 1
            }
        }
        let rawPercent = Double(daysWithRecord) / Double(totalDays) * 100
        return (rawPercent * 10).rounded() / 10
    }
    
    /// 直近の記録日
    var lastRecordDate: Date? {
        records.max(by: { $0.date < $1.date })?.date
    }
    
    /// 今日の記録数
    func todayCount() -> Int {
        records(for: Date()).count
    }
    
    // 薬（サプリ含む）
    func addMedication(_ item: MedicationItem) {
        var newItem = item
        if medications.isEmpty {
            newItem.colorIndex = 0
        } else {
            let maxIndex = medications.map(\.colorIndex).max() ?? -1
            newItem.colorIndex = maxIndex + 1
        }
        medications.append(newItem)
    }
    
    func deleteMedication(_ item: MedicationItem) {
        medications.removeAll { $0.id == item.id }
        archivedMedications.removeAll { $0.id == item.id }
        medicationLogs.removeAll { $0.medicationId == item.id }
    }
    
    func updateMedication(_ item: MedicationItem, name: String, startDate: Date?) {
        guard let index = medications.firstIndex(where: { $0.id == item.id }) else { return }
        medications[index] = MedicationItem(id: item.id, name: name, startDate: startDate, colorIndex: item.colorIndex)
    }
    
    // 薬の服用ログ（日別）
    func medicationLogs(for date: Date) -> [MedicationLog] {
        let calendar = Calendar.current
        return medicationLogs.filter { calendar.isDate($0.date, inSameDayAs: date) }
    }
    
    func hasMedicationLog(on date: Date, medicationId: UUID) -> Bool {
        medicationLogs(for: date).contains { $0.medicationId == medicationId }
    }
    
    func addMedicationLog(date: Date, medicationId: UUID) {
        guard !hasMedicationLog(on: date, medicationId: medicationId) else { return }
        medicationLogs.append(MedicationLog(date: date, medicationId: medicationId))
    }
    
    func removeMedicationLog(date: Date, medicationId: UUID) {
        medicationLogs.removeAll { log in
            Calendar.current.isDate(log.date, inSameDayAs: date) && log.medicationId == medicationId
        }
    }
}
