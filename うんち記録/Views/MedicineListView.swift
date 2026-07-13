//
//  MedicineListView.swift
//  うんち記録
//
//  服用中の薬一覧（編集用）
//

import SwiftUI

struct MedicineListView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    
    let onSelect: (MedicationItem) -> Void
    let onAdd: () -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(dataStore.medications) { item in
                    Button {
                        AppAnalytics.log(.medicine_list_row_tap)
                        onSelect(item)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.body)
                                .foregroundStyle(AppColors.textPrimary)
                            if let date = item.startDate {
                                Text(formatDate(date))
                                    .font(.caption)
                                    .foregroundStyle(AppColors.textSecondary)
                            }
                        }
                    }
                }
                
                Button {
                    AppAnalytics.log(.medicine_list_add_tap)
                    onAdd()
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("薬を追加")
                    }
                    .foregroundStyle(AppColors.accentPink)
                }
            }
            .navigationTitle("服用中の薬")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("閉じる") {
                        AppAnalytics.log(.medicine_list_close_tap)
                        dismiss()
                    }
                    .foregroundStyle(AppColors.accentPink)
                }
            }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd~"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}
