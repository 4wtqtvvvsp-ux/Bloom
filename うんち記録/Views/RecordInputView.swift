//
//  RecordInputView.swift
//  うんち記録
//
//  お通じ入力シート（可愛いUI、直接的な表現なし）
//

import SwiftUI

struct RecordInputView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    
    let selectedDate: Date
    @State private var selectedCondition: BowelCondition = .normal
    @State private var selectedAmount: BowelAmount = .medium
    @State private var note: String = ""
    @State private var imageIds: [String] = []
    @State private var showImageSourcePicker = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // 状態選択
                    VStack(alignment: .leading, spacing: 12) {
                        Text("今日のおなかの調子は？")
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                        
                        VStack(spacing: 12) {
                            ForEach(BowelCondition.allCases, id: \.self) { condition in
                                conditionRow(condition)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("量は？")
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                        VStack(spacing: 12) {
                            ForEach(BowelAmount.allCases, id: \.self) { amount in
                                amountRow(amount)
                            }
                        }
                    }
                    
                    // 写真・画像
                    VStack(alignment: .leading, spacing: 8) {
                        Text("写真（任意）")
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(imageIds, id: \.self) { id in
                                    if let uiImage = ImageStore.load(id: id) {
                                        ZStack(alignment: .topTrailing) {
                                            Image(uiImage: uiImage)
                                                .resizable()
                                                .scaledToFill()
                                                .frame(width: 80, height: 80)
                                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                            Button {
                                                AppAnalytics.log(.record_input_photo_remove_tap)
                                                ImageStore.delete(id: id)
                                                imageIds.removeAll { $0 == id }
                                            } label: {
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.title3)
                                                    .foregroundStyle(.white)
                                                    .shadow(radius: 2)
                                            }
                                            .offset(x: 6, y: -6)
                                        }
                                    }
                                }
                                addImageButton
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    
                    // この日の服用
                    if !dataStore.medications.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("この日の服用")
                                .font(.headline)
                                .foregroundStyle(AppColors.textPrimary)
                            ForEach(dataStore.medications) { med in
                                medicationToggleRow(med)
                            }
                        }
                    }
                    
                    // メモ（任意）
                    VStack(alignment: .leading, spacing: 8) {
                        Text("メモ（任意）")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textSecondary)
                        
                        TextField("気になったことがあれば…", text: $note, axis: .vertical)
                            .textFieldStyle(.plain)
                            .padding(12)
                            .background(AppColors.pastelBlueLight)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .lineLimit(3...6)
                    }
                }
                .padding(24)
            }
            .background(AppColors.background)
            .navigationTitle("お通じを記録")
            .navigationBarTitleDisplayMode(.inline)
            .confirmationDialog("画像を追加", isPresented: $showImageSourcePicker) {
                Button("カメラで撮影") {
                    AppAnalytics.log(.record_input_photo_source_camera)
                    showCamera = true
                }
                Button("フォトライブラリから選択") {
                    AppAnalytics.log(.record_input_photo_source_library)
                    showPhotoLibrary = true
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("写真の追加方法を選んでください")
            }
            .fullScreenCover(isPresented: $showCamera) {
                ImagePickerView(
                    sourceType: .camera,
                    onSelect: { addImage($0) },
                    onCancel: { AppAnalytics.log(.image_picker_cancel, parameters: ["source": "camera"]) }
                )
            }
            .fullScreenCover(isPresented: $showPhotoLibrary) {
                ImagePickerView(
                    sourceType: .photoLibrary,
                    onSelect: { addImage($0) },
                    onCancel: { AppAnalytics.log(.image_picker_cancel, parameters: ["source": "library"]) }
                )
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        AppAnalytics.log(.record_input_cancel)
                        dismiss()
                    }
                    .foregroundStyle(AppColors.accentPink)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        save()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(AppColors.accentPink)
                }
            }
        }
    }
    
    private func conditionRow(_ condition: BowelCondition) -> some View {
        let isSelected = selectedCondition == condition
        
        return Button {
            AppAnalytics.log(.record_input_select_condition, parameters: ["condition": condition.rawValue])
            selectedCondition = condition
        } label: {
            HStack(spacing: 16) {
                ConditionIconView(condition: condition, size: 52)
                    .frame(width: 60, alignment: .center)
                
                Text(condition.displayName)
                    .font(.body)
                    .foregroundStyle(AppColors.textPrimary)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.accentPink)
                }
            }
            .padding(16)
            .background(isSelected ? AppColors.pastelPink.opacity(0.5) : AppColors.pastelBlueLight)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.accentPink : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func amountRow(_ amount: BowelAmount) -> some View {
        let isSelected = selectedAmount == amount
        return Button {
            AppAnalytics.log(.record_input_select_amount, parameters: ["amount": amount.rawValue])
            selectedAmount = amount
        } label: {
            HStack(spacing: 16) {
                Text(amount.displayName)
                    .font(.body)
                    .foregroundStyle(AppColors.textPrimary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppColors.accentPink)
                }
            }
            .padding(16)
            .background(isSelected ? AppColors.pastelPink.opacity(0.5) : AppColors.pastelBlueLight)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? AppColors.accentPink : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private func medicationToggleRow(_ med: MedicationItem) -> some View {
        let isTaken = dataStore.hasMedicationLog(on: selectedDate, medicationId: med.id)
        return Button {
            if isTaken {
                AppAnalytics.log(.record_input_medication_toggle, parameters: ["medication_id": med.id.uuidString, "taken": "0"])
                dataStore.removeMedicationLog(date: selectedDate, medicationId: med.id)
            } else {
                AppAnalytics.log(.record_input_medication_toggle, parameters: ["medication_id": med.id.uuidString, "taken": "1"])
                dataStore.addMedicationLog(date: selectedDate, medicationId: med.id)
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
    
    private var addImageButton: some View {
        Button {
            AppAnalytics.log(.record_input_photo_add_tap)
            showImageSourcePicker = true
        } label: {
            VStack(spacing: 8) {
                Image(systemName: "camera.fill")
                    .font(.title2)
                Text("写真を追加")
                    .font(.caption2)
            }
            .foregroundStyle(AppColors.accentPink)
            .frame(width: 80, height: 80)
            .background(AppColors.pastelPink.opacity(0.3))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
    
    private func addImage(_ image: UIImage) {
        if let id = ImageStore.save(image) {
            imageIds.append(id)
        }
    }
    
    private func save() {
        AppAnalytics.log(
            .record_input_save,
            parameters: [
                "condition": selectedCondition.rawValue,
                "amount": selectedAmount.rawValue,
                "photo_count": "\(imageIds.count)"
            ]
        )
        let record = BowelRecord(
            date: selectedDate,
            condition: selectedCondition,
            amount: selectedAmount,
            note: note.isEmpty ? nil : note,
            imageIds: imageIds
        )
        dataStore.add(record)
        dismiss()
    }
}

#Preview {
    RecordInputView(selectedDate: Date())
        .environment(DataStore.shared)
        .environment(BowelConditionColorSettings.shared)
}
