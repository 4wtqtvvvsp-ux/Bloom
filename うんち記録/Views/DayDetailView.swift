//
//  DayDetailView.swift
//  うんち記録
//
//  日付タップ時に表示する記録一覧・編集
//

import SwiftUI
import UIKit

struct DayDetailView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    
    let date: Date
    @State private var recordToEdit: BowelRecord?
    @State private var showAddRecord = false
    /// 服用中の薬のチェック状態（保存まで DataStore に書かない）
    @State private var draftTakenMedicationIds: Set<UUID> = []
    
    private var calendar: Calendar { Calendar.current }
    private var dayRecords: [BowelRecord] {
        dataStore.records(for: date)
            .sorted { $0.date > $1.date }
    }
    
    /// この日にログがあるアーカイブ済みの薬（表示のみ）
    private var archivedMedsLoggedThisDay: [MedicationItem] {
        let ids = Set(dataStore.medicationLogs(for: date).map(\.medicationId))
        return dataStore.archivedMedications.filter { ids.contains($0.id) }
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 日付表示
                    Text(dateString(from: date))
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                        .padding(.top, 8)
                    
                    // この日の服用
                    if !dataStore.medications.isEmpty || !archivedMedsLoggedThisDay.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("この日の服用")
                                .font(.subheadline.bold())
                                .foregroundStyle(AppColors.textPrimary)
                            ForEach(dataStore.medications) { med in
                                medicationToggleRow(med)
                            }
                            ForEach(archivedMedsLoggedThisDay) { med in
                                archivedMedicationRow(med)
                            }
                        }
                    }
                    
                    // お通じ記録一覧
                    if !dayRecords.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("お通じ")
                                .font(.subheadline.bold())
                                .foregroundStyle(AppColors.textPrimary)
                            ForEach(dayRecords) { record in
                                recordRow(record)
                            }
                        }
                    }
                    
                    // 新規追加ボタン
                    Button {
                        AppAnalytics.log(.day_detail_add_record_tap)
                        AppAnalytics.log(.sheet_open_record_input, parameters: ["source": "day_detail"])
                        showAddRecord = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("お通じを追加")
                        }
                        .font(.body)
                        .foregroundStyle(AppColors.accentPink)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(AppColors.pastelPink.opacity(0.3))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                }
                .padding(24)
            }
            .background(AppColors.background)
            .navigationTitle("記録")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        AppAnalytics.log(.day_detail_toolbar_close)
                        dismiss()
                    }
                    .foregroundStyle(AppColors.accentPink)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        AppAnalytics.log(.day_detail_toolbar_save)
                        saveMedicationDraft()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.accentPink)
                }
            }
            .task {
                loadMedicationDraftFromStore()
            }
            .sheet(item: $recordToEdit) { record in
                RecordEditView(record: record)
                    .environment(dataStore)
            }
            .sheet(isPresented: $showAddRecord) {
                RecordInputView(selectedDate: date)
                    .environment(dataStore)
            }
        }
    }
    
    private func loadMedicationDraftFromStore() {
        draftTakenMedicationIds = Set(
            dataStore.medications
                .filter { dataStore.hasMedicationLog(on: date, medicationId: $0.id) }
                .map(\.id)
        )
    }
    
    private func saveMedicationDraft() {
        for med in dataStore.medications {
            let should = draftTakenMedicationIds.contains(med.id)
            let saved = dataStore.hasMedicationLog(on: date, medicationId: med.id)
            if should, !saved {
                dataStore.addMedicationLog(date: date, medicationId: med.id)
            }
            if !should, saved {
                dataStore.removeMedicationLog(date: date, medicationId: med.id)
            }
        }
    }
    
    private func medicationToggleRow(_ med: MedicationItem) -> some View {
        let isTaken = draftTakenMedicationIds.contains(med.id)
        return Button {
            if isTaken {
                AppAnalytics.log(.day_detail_medication_draft_toggle, parameters: ["medication_id": med.id.uuidString, "taken": "0"])
                draftTakenMedicationIds.remove(med.id)
            } else {
                AppAnalytics.log(.day_detail_medication_draft_toggle, parameters: ["medication_id": med.id.uuidString, "taken": "1"])
                draftTakenMedicationIds.insert(med.id)
            }
        } label: {
            HStack(spacing: 12) {
                Circle()
                    .fill(med.calendarColor)
                    .frame(width: 12, height: 12)
                Text(med.name)
                    .font(.body)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                Image(systemName: isTaken ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isTaken ? AppColors.accentPink : AppColors.textMuted)
            }
            .padding(16)
            .background(AppColors.pastelBlueLight)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private func archivedMedicationRow(_ med: MedicationItem) -> some View {
        HStack(spacing: 12) {
            Circle()
                .fill(med.calendarColor)
                .frame(width: 12, height: 12)
            Text(med.name)
                .font(.body)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppColors.accentPink)
        }
        .padding(16)
        .background(AppColors.pastelBlueLight)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    private func recordRow(_ record: BowelRecord) -> some View {
        Button {
            AppAnalytics.log(.day_detail_open_record_edit)
            recordToEdit = record
        } label: {
            HStack(spacing: 16) {
                ConditionIconView(condition: record.condition, size: 44)
                    .frame(width: 52, alignment: .center)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(record.condition.displayName)
                        .font(.body)
                        .foregroundStyle(AppColors.textPrimary)
                    Text("量：\(record.amount.displayName)")
                        .font(.subheadline)
                        .foregroundStyle(AppColors.textSecondary)
                    if let note = record.note, !note.isEmpty {
                        Text(note)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                            .lineLimit(2)
                    }
                    if !record.imageIds.isEmpty, let firstId = record.imageIds.first,
                       let uiImage = ImageStore.load(id: firstId) {
                        ZStack(alignment: .bottomTrailing) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 44, height: 44)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                            if record.imageIds.count > 1 {
                                Text("+\(record.imageIds.count - 1)")
                                    .font(.caption2)
                                    .foregroundStyle(.white)
                                    .padding(2)
                                    .background(.black.opacity(0.6))
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                        }
                        .padding(.top, 4)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(AppColors.textMuted)
            }
            .padding(16)
            .background(AppColors.pastelBlueLight)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
    
    private func dateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月d日（E）"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

// recordToEdit 用の Optional バインディングのため、BowelRecord を Identifiable に（既に準拠済み）
// sheet(item:) を使うので問題なし
