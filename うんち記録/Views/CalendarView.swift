//
//  CalendarView.swift
//  うんち記録
//
//  カレンダーで記録を確認
//

import SwiftUI

private struct SelectableDate: Identifiable {
    let id = UUID()
    let date: Date
}

struct CalendarView: View {
    @Environment(DataStore.self) private var dataStore
    @State private var currentMonth = Date()
    @State private var selectedDateForDetail: SelectableDate?
    @State private var medicationToDelete: MedicationItem?
    @State private var showDeleteMedicationAlert = false
    
    private var calendar: Calendar { Calendar.current }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 画面上部に固定：月切り替え
                HStack {
                    Button {
                        AppAnalytics.log(.calendar_month_prev)
                        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.body.bold())
                            .foregroundStyle(AppColors.accentPink)
                    }
                    
                    Spacer()
                    
                    Text(monthYearString(from: currentMonth))
                        .font(.title3.bold())
                        .foregroundStyle(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Button {
                        AppAnalytics.log(.calendar_month_next)
                        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
                    } label: {
                        Image(systemName: "chevron.right")
                            .font(.body.bold())
                            .foregroundStyle(AppColors.accentPink)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(AppColors.background)
                .overlay(alignment: .bottom) {
                    Rectangle()
                        .fill(AppColors.border)
                        .frame(height: 1)
                }
                
                ScrollView {
                    VStack(spacing: 24) {
                        // 曜日ヘッダー
                        HStack(spacing: 0) {
                            ForEach(["日", "月", "火", "水", "木", "金", "土"], id: \.self) { day in
                                Text(day)
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .padding(.horizontal, 16)
                    
                    // カレンダーグリッド
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                        ForEach(Array(daysInMonth().enumerated()), id: \.offset) { _, date in
                            if let date = date {
                                dayCell(for: date)
                            } else {
                                Color.clear
                                    .frame(height: 78)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    // おなかの調子の内訳（パーセンテージ付き）
                    VStack(alignment: .leading, spacing: 12) {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(BowelCondition.allCases, id: \.self) { condition in
                                HStack(spacing: 4) {
                                    ConditionIconView(condition: condition, size: 24)
                                        .frame(width: 28, height: 28, alignment: .center)
                                    Text("\(condition.displayName) \(conditionPercentage(for: condition))%")
                                        .font(.caption2)
                                        .foregroundStyle(AppColors.textSecondary)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 8) {
                            ForEach(BowelAmount.allCases, id: \.self) { amount in
                                HStack(spacing: 4) {
                                    Text("\(amount.displayName) \(amountPercentage(for: amount))%")
                                        .font(.caption2)
                                        .foregroundStyle(AppColors.textSecondary)
                                        .lineLimit(1)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                        }
                        
                        // 薬（色付き丸）— 服用中・服用をやめた薬の両方
                        if !medicationLegendItems.isEmpty {
                            VStack(alignment: .leading, spacing: 6) {
                                Text("薬")
                                    .font(.caption2.bold())
                                    .foregroundStyle(AppColors.textSecondary)
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 8) {
                                    ForEach(medicationLegendItems) { med in
                                        HStack(spacing: 6) {
                                            Circle()
                                                .fill(med.calendarColor)
                                                .frame(width: 8, height: 8)
                                            Text(med.name)
                                                .font(.caption2)
                                                .foregroundStyle(AppColors.textSecondary)
                                                .lineLimit(1)
                                        }
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .contentShape(Rectangle())
                                        .onLongPressGesture(minimumDuration: 0.5) {
                                            AppAnalytics.log(.calendar_medication_legend_long_press, parameters: ["medication_id": med.id.uuidString])
                                            medicationToDelete = med
                                            showDeleteMedicationAlert = true
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(.top, 16)
                }
                .padding(.vertical, 24)
                }
            }
            .background(AppColors.background)
            .navigationTitle("カレンダー")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(item: $selectedDateForDetail) { item in
                DayDetailView(date: item.date)
                    .environment(dataStore)
                    .environment(BowelConditionColorSettings.shared)
            }
            .alert("この薬のデータを削除", isPresented: $showDeleteMedicationAlert) {
                Button("キャンセル", role: .cancel) {
                    AppAnalytics.log(.calendar_medication_delete_cancel)
                    medicationToDelete = nil
                }
                Button("削除", role: .destructive) {
                    AppAnalytics.log(.calendar_medication_delete_confirm)
                    if let med = medicationToDelete {
                        dataStore.deleteMedication(med)
                    }
                    medicationToDelete = nil
                }
            } message: {
                Text(
                    medicationToDelete.map { med in
                        "「\(med.name)」の服用記録と登録をすべて削除します。この操作は取り消せません。"
                    } ?? "この薬に関するデータをすべて削除します。この操作は取り消せません。"
                )
            }
        }
    }
    
    private func daysInMonth() -> [Date?] {
        guard let range = calendar.range(of: .day, in: .month, for: currentMonth),
              let firstDay = calendar.date(from: calendar.dateComponents([.year, .month], from: currentMonth)) else {
            return []
        }
        
        let firstWeekday = calendar.component(.weekday, from: firstDay) - 1
        let emptyDays = Array(repeating: nil as Date?, count: firstWeekday)
        let days = range.compactMap { day -> Date? in
            calendar.date(byAdding: .day, value: day - 1, to: firstDay)
        }
        return emptyDays + days.map { $0 as Date? }
    }
    
    private func dayCell(for date: Date) -> some View {
        let dayRecords = dataStore.records(for: date).sorted { $0.date < $1.date }
        let hasRecord = !dayRecords.isEmpty
        let logs = dataStore.medicationLogs(for: date)
        let medicationsForDate = logs.compactMap { log in
            dataStore.medication(for: log.medicationId)
        }
        let hasAnyRecord = hasRecord || !medicationsForDate.isEmpty
        let isCurrentMonth = calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
        let isToday = calendar.isDateInToday(date)
        
        let cellContent = VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.subheadline)
                .foregroundStyle(isCurrentMonth ? AppColors.textPrimary : AppColors.textMuted)
            
            // 上段：薬の丸（色付き）— 高さを確保してアイコン周りに余白
            Group {
                if !medicationsForDate.isEmpty {
                    HStack(spacing: 3) {
                        ForEach(medicationsForDate, id: \.id) { med in
                            Circle()
                                .fill(med.calendarColor)
                                .frame(width: 7, height: 7)
                        }
                    }
                }
            }
            .frame(height: 10)
            
            // お通じ：固さのみ（量は日セルでは表示しない）
            if !dayRecords.isEmpty {
                HStack(spacing: 3) {
                    ForEach(dayRecords) { rec in
                        ConditionIconView(condition: rec.condition, size: pairIconSize(for: dayRecords.count))
                    }
                }
            }
        }
        .frame(width: 42, height: 78)
        .background(
            Group {
                if isToday {
                    AppColors.pastelPink
                } else if hasAnyRecord {
                    AppColors.pastelBlue.opacity(0.5)
                } else {
                    Color.clear
                }
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(hasAnyRecord ? AppColors.accentPink : .clear, lineWidth: 2)
        )
        
        return Button {
            AppAnalytics.log(.calendar_day_tap)
            selectedDateForDetail = SelectableDate(date: date)
        } label: {
            cellContent
        }
        .buttonStyle(.plain)
    }
    
    private func pairIconSize(for recordCount: Int) -> CGFloat {
        switch recordCount {
        case 1: return 36
        case 2: return 19
        case 3: return 12
        default: return 8
        }
    }
    
    private func monthYearString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    /// 凡例用：服用中の薬 → 続けて服用をやめた薬（ID の重複は除く）
    private var medicationLegendItems: [MedicationItem] {
        var seen = Set<UUID>()
        var result: [MedicationItem] = []
        for med in dataStore.medications + dataStore.archivedMedications {
            if seen.insert(med.id).inserted { result.append(med) }
        }
        return result
    }
    
    /// 表示中の月における、指定状態の記録の割合（％）
    private func conditionPercentage(for condition: BowelCondition) -> Int {
        let monthRecords = dataStore.records.filter { calendar.isDate($0.date, equalTo: currentMonth, toGranularity: .month) }
        let total = monthRecords.count
        guard total > 0 else { return 0 }
        let count = monthRecords.filter { $0.condition == condition }.count
        return Int(round(Double(count) / Double(total) * 100))
    }
    
    /// 表示中の月における、指定量の記録の割合（％）
    private func amountPercentage(for amount: BowelAmount) -> Int {
        let monthRecords = dataStore.records.filter { calendar.isDate($0.date, equalTo: currentMonth, toGranularity: .month) }
        let total = monthRecords.count
        guard total > 0 else { return 0 }
        let count = monthRecords.filter { $0.amount == amount }.count
        return Int(round(Double(count) / Double(total) * 100))
    }
}

#Preview {
    CalendarView()
        .environment(DataStore.shared)
        .environment(BowelConditionColorSettings.shared)
}
