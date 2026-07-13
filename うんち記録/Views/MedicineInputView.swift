//
//  MedicineInputView.swift
//  うんち記録
//
//  薬の追加・編集（サプリ含む）
//

import SwiftUI

struct MedicineInputView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    
    var editingItem: (id: UUID, name: String, startDate: Date?, colorIndex: Int)? = nil
    
    @State private var name: String = ""
    @State private var startDate: Date = Date()
    @State private var hasStartDate: Bool = true
    @State private var showStopTakingConfirm = false
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("薬やサプリ名を入力", text: $name)
                } header: {
                    Text("薬の名前")
                }
                
                if editingItem != nil {
                    Section {
                        Button {
                            AppAnalytics.log(.medicine_input_stop_taking_dialog)
                            showStopTakingConfirm = true
                        } label: {
                            Text("服用をやめる")
                                .frame(maxWidth: .infinity)
                        }
                        .foregroundStyle(AppColors.accentPink)
                    }
                }
                
                Section {
                    Toggle("開始日を記録", isOn: $hasStartDate)
                    if hasStartDate {
                        DatePicker("開始日", selection: $startDate, displayedComponents: .date)
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                    }
                } header: {
                    Text("服用開始")
                }
            }
            .navigationTitle(editingItem != nil ? "編集" : "薬を追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        AppAnalytics.log(.medicine_input_cancel)
                        dismiss()
                    }
                    .foregroundStyle(AppColors.accentPink)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(name.isEmpty ? AppColors.textMuted : AppColors.accentPink)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                if let item = editingItem {
                    name = item.name
                    if let date = item.startDate {
                        startDate = date
                        hasStartDate = true
                    } else {
                        hasStartDate = false
                    }
                }
            }
            .confirmationDialog("服用中の薬から外しますか？", isPresented: $showStopTakingConfirm, titleVisibility: .visible) {
                Button("服用をやめる") {
                    AppAnalytics.log(.medicine_input_stop_taking_confirm)
                    stopTaking()
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("過去に付けた服用記録はカレンダーにそのまま残ります。")
            }
        }
    }
    
    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let dateToSave = hasStartDate ? startDate : nil
        
        if let item = editingItem {
            AppAnalytics.log(.medicine_input_save, parameters: ["mode": "edit"])
            dataStore.updateMedication(MedicationItem(id: item.id, name: trimmed, startDate: dateToSave, colorIndex: item.colorIndex), name: trimmed, startDate: dateToSave)
        } else {
            AppAnalytics.log(.medicine_input_save, parameters: ["mode": "new"])
            dataStore.addMedication(MedicationItem(name: trimmed, startDate: dateToSave))
        }
        dismiss()
    }
    
    private func stopTaking() {
        guard let item = editingItem else { return }
        dataStore.stopTakingMedication(
            MedicationItem(id: item.id, name: item.name, startDate: item.startDate, colorIndex: item.colorIndex)
        )
        dismiss()
    }
}

#Preview {
    MedicineInputView()
        .environment(DataStore.shared)
}
