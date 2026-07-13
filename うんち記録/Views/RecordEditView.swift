//
//  RecordEditView.swift
//  うんち記録
//
//  記録の編集（アイコン・メモ・写真）
//

import SwiftUI
import UIKit

struct RecordEditView: View {
    @Environment(DataStore.self) private var dataStore
    @Environment(\.dismiss) private var dismiss
    
    let record: BowelRecord
    @State private var selectedCondition: BowelCondition
    @State private var selectedAmount: BowelAmount
    @State private var note: String
    @State private var imageIds: [String]
    @State private var showDeleteAlert = false
    @State private var showImageSourcePicker = false
    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    
    init(record: BowelRecord) {
        self.record = record
        _selectedCondition = State(initialValue: record.condition)
        _selectedAmount = State(initialValue: record.amount)
        _note = State(initialValue: record.note ?? "")
        _imageIds = State(initialValue: record.imageIds)
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    // 状態選択
                    VStack(alignment: .leading, spacing: 12) {
                        Text("おなかの調子")
                            .font(.headline)
                            .foregroundStyle(AppColors.textPrimary)
                        
                        VStack(spacing: 12) {
                            ForEach(BowelCondition.allCases, id: \.self) { condition in
                                conditionRow(condition)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text("量")
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
                                                AppAnalytics.log(.record_edit_photo_remove_tap)
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
                    
                    // メモ
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
                    
                    // 削除ボタン
                    Button(role: .destructive) {
                        AppAnalytics.log(.record_edit_delete_tap)
                        showDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("記録を削除")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                    }
                    .padding(.top, 24)
                }
                .padding(24)
            }
            .background(AppColors.background)
            .navigationTitle("記録を編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        AppAnalytics.log(.record_edit_cancel)
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
            .alert("記録を削除", isPresented: $showDeleteAlert) {
                Button("キャンセル", role: .cancel) {
                    AppAnalytics.log(.record_edit_delete_cancel)
                }
                Button("削除", role: .destructive) {
                    AppAnalytics.log(.record_edit_delete_confirm)
                    dataStore.delete(record)
                    dismiss()
                }
            } message: {
                Text("この記録を削除しますか？")
            }
            .confirmationDialog("画像を追加", isPresented: $showImageSourcePicker) {
                Button("カメラで撮影") {
                    AppAnalytics.log(.record_edit_photo_source_camera)
                    showCamera = true
                }
                Button("フォトライブラリから選択") {
                    AppAnalytics.log(.record_edit_photo_source_library)
                    showPhotoLibrary = true
                }
                Button("キャンセル", role: .cancel) {}
            } message: {
                Text("写真の追加方法を選んでください")
            }
            .fullScreenCover(isPresented: $showCamera) {
                ImagePickerView(sourceType: .camera, onSelect: addImage, onCancel: {
                    AppAnalytics.log(.image_picker_cancel, parameters: ["source": "camera"])
                })
            }
            .fullScreenCover(isPresented: $showPhotoLibrary) {
                ImagePickerView(sourceType: .photoLibrary, onSelect: addImage, onCancel: {
                    AppAnalytics.log(.image_picker_cancel, parameters: ["source": "library"])
                })
            }
        }
    }
    
    private var addImageButton: some View {
        Button {
            AppAnalytics.log(.record_edit_photo_add_tap)
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
    
    private func conditionRow(_ condition: BowelCondition) -> some View {
        let isSelected = selectedCondition == condition
        
        return Button {
            AppAnalytics.log(.record_edit_select_condition, parameters: ["condition": condition.rawValue])
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
            AppAnalytics.log(.record_edit_select_amount, parameters: ["amount": amount.rawValue])
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
    
    private func save() {
        AppAnalytics.log(
            .record_edit_save,
            parameters: [
                "condition": selectedCondition.rawValue,
                "amount": selectedAmount.rawValue,
                "photo_count": "\(imageIds.count)"
            ]
        )
        dataStore.update(record, condition: selectedCondition, amount: selectedAmount, note: note.isEmpty ? nil : note, imageIds: imageIds)
        dismiss()
    }
}

#Preview {
    RecordEditView(record: BowelRecord(date: Date(), condition: .normal, amount: .medium, note: "テストメモ"))
        .environment(DataStore.shared)
        .environment(BowelConditionColorSettings.shared)
}
