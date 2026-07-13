//
//  HomeView.swift
//  うんち記録
//
//  生理記録アプリ風のメイン画面
//

import SwiftUI
import Combine

private struct MonthPage: Identifiable {
    let id: Int
    let date: Date
}

private enum LastBowelRecency {
    case hours(Int)
    case days(Int)
}

struct HomeView: View {
    @Environment(DataStore.self) private var dataStore
    @State private var showRecordInput = false
    @State private var showMedicineInput = false
    @State private var showMedicineList = false
    @State private var editingMedication: MedicationItem?
    @State private var selectedMonthIndex: Int = 12  // 0=12ヶ月前, 12=今月
    @State private var showLastBowelStats = false
    
    private var calendar: Calendar { Calendar.current }
    private var monthPages: [MonthPage] {
        (-12...1).enumerated().compactMap { index, offset in
            calendar.date(byAdding: .month, value: offset, to: Date()).map {
                MonthPage(id: index, date: $0)
            }
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // ヘッダー（3カラム：薬・月・排便率）
                headerSection
                
                // メインコンテンツ（円形グラフ＋入力ボタン）
                mainContentSection
                
                Spacer(minLength: 40)
                
                // 薬の追加セクション
                addMedicineSection
                
                Spacer(minLength: 100)
            }
        }
        .background(AppColors.background)
        .sheet(isPresented: $showRecordInput) {
            RecordInputView(selectedDate: Date())
                .environment(dataStore)
        }
        .sheet(isPresented: $showMedicineInput) {
            if let item = editingMedication {
                MedicineInputView(editingItem: (item.id, item.name, item.startDate, item.colorIndex))
                    .environment(dataStore)
            } else {
                MedicineInputView()
                    .environment(dataStore)
            }
        }
        .onChange(of: showMedicineInput) { _, newValue in
            if !newValue { editingMedication = nil }
        }
        .onChange(of: showMedicineList) { _, isOpen in
            if isOpen { AppAnalytics.log(.sheet_open_medicine_list) }
        }
        .sheet(isPresented: $showMedicineList) {
            MedicineListView(
                onSelect: { item in
                    AppAnalytics.log(.sheet_open_medicine_input, parameters: ["source": "home_medication_list_edit"])
                    showMedicineList = false
                    editingMedication = item
                    showMedicineInput = true
                },
                onAdd: {
                    AppAnalytics.log(.sheet_open_medicine_input, parameters: ["source": "home_medication_list_new"])
                    showMedicineList = false
                    editingMedication = nil
                    showMedicineInput = true
                }
            )
            .environment(dataStore)
        }
        .onReceive(Timer.publish(every: 5, on: .main, in: .common).autoconnect()) { _ in
            showLastBowelStats.toggle()
        }
    }
    
    /// 直近のお通じ記録からの経過（24時間未満は時間、以上は日付ベースの「日前」）
    private var lastBowelRecencyInfo: LastBowelRecency? {
        guard let last = dataStore.lastRecordDate else { return nil }
        let interval = Date().timeIntervalSince(last)
        guard interval >= 0 else { return nil }
        if interval < 86400 {
            let h = max(1, Int(ceil(interval / 3600)))
            return .hours(h)
        }
        let days = calendar.dateComponents([.day], from: calendar.startOfDay(for: last), to: calendar.startOfDay(for: Date())).day ?? 0
        return .days(max(days, 1))
    }
    
    private var lastBowelSkyBlue: Color { AppColors.accentBlue }
    
    @ViewBuilder
    private var lastBowelStatsView: some View {
        if let info = lastBowelRecencyInfo {
            switch info {
            case .hours(let h):
                Text("前回の排便から\(h)時間")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(lastBowelSkyBlue)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.75)
                    .lineLimit(2)
                    .accessibilityLabel("前回の排便から\(h)時間")
            case .days(let d):
                VStack(spacing: 0) {
                    Text("前回の排便")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(lastBowelSkyBlue)
                    HStack(alignment: .bottom, spacing: 4) {
                        Text("\(d)")
                            .font(.system(size: 44, weight: .bold))
                            .foregroundStyle(lastBowelSkyBlue)
                        Text("日前")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(lastBowelSkyBlue)
                            .padding(.bottom, 4)
                    }
                    .padding(.top, -6)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("前回の排便から\(d)日前")
            }
        } else {
            Text("記録がありません")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(lastBowelSkyBlue)
                .multilineTextAlignment(.center)
                .accessibilityLabel("お通じの記録がありません")
        }
    }
    
    // MARK: - ヘッダー（3カラム：薬・月・排便率）
    private var headerSection: some View {
        TabView(selection: $selectedMonthIndex) {
            ForEach(monthPages) { page in
                headerRow(for: page.date)
                    .tag(page.id)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 110)
        .padding(.horizontal, 24)
        .padding(.top, 20)
        .padding(.bottom, 24)
    }
    
    private func headerRow(for month: Date) -> some View {
        HStack(alignment: .top, spacing: 12) {
            // 左：服用中の薬
            Button {
                if dataStore.medications.count == 1 {
                    AppAnalytics.log(.home_medication_header_tap)
                    AppAnalytics.log(.sheet_open_medicine_input, parameters: ["source": "home_header_single"])
                    editingMedication = dataStore.medications.first
                    showMedicineInput = true
                } else if dataStore.medications.count > 1 {
                    AppAnalytics.log(.home_medication_header_tap)
                    showMedicineList = true
                }
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("服用中の薬")
                        .font(.caption.bold())
                        .foregroundStyle(AppColors.iconColor)
                    if dataStore.medications.isEmpty {
                        Text("未登録")
                            .font(.subheadline)
                            .foregroundStyle(AppColors.textMuted)
                    } else {
                        Text(medicationNamesText)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.iconColor)
                            .multilineTextAlignment(.leading)
                        if let earliestDate = earliestStartDate {
                            Text(startDateString(from: earliestDate))
                                .font(.subheadline)
                                .foregroundStyle(AppColors.iconColor)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .disabled(dataStore.medications.isEmpty)
            
            // 中央：月（大きく）
            Text(monthString(from: month))
                .font(.system(size: 36, weight: .light))
                .foregroundStyle(AppColors.iconColor)
                .frame(maxWidth: .infinity)
            
            // 右：排便率
            VStack(alignment: .trailing, spacing: 4) {
                Text("排便率")
                    .font(.caption)
                    .foregroundStyle(AppColors.iconColor)
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(String(format: "%.1f", dataStore.bowelMovementRate(for: month)))
                        .font(.system(size: 36, weight: .light))
                        .foregroundStyle(AppColors.iconColor)
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.45)
                        .frame(minWidth: 0, alignment: .trailing)
                    Text("%")
                        .font(.system(size: 14, weight: .light))
                        .foregroundStyle(AppColors.iconColor)
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
    
    private func monthString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "M月"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
    
    /// 複数の薬を「、」で区切って表示
    private var medicationNamesText: String {
        dataStore.medications.map(\.name).joined(separator: "、")
    }
    
    private var earliestStartDate: Date? {
        dataStore.medications.compactMap(\.startDate).min()
    }
    
    private func startDateString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        formatter.locale = Locale(identifier: "ja_JP")
        return "\(formatter.string(from: date))~"
    }
    
    // MARK: - メインコンテンツ
    private var mainContentSection: some View {
        ZStack {
            // 円形プログレス（参考画像風）
            Circle()
                .trim(from: 0, to: 0.75)
                .stroke(AppColors.pastelPink, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 200, height: 200)
            
            Circle()
                .trim(from: 0, to: 0.5)
                .stroke(AppColors.pastelBlue, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .frame(width: 170, height: 170)
            
            // 中央コンテンツ（アイコンと前回の排便を5秒ごとに交代）
            VStack(spacing: 16) {
                Group {
                    if showLastBowelStats {
                        lastBowelStatsView
                    } else {
                        Image("usagi")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 48, height: 48)
                            .accessibilityLabel("Bloom")
                    }
                }
                .frame(width: 120, height: 72)
                .contentShape(Rectangle())
                .onTapGesture {
                    AppAnalytics.log(.home_stats_center_tap)
                    showLastBowelStats.toggle()
                }
                .accessibilityAddTraits(.isButton)
                .accessibilityHint("タップでアイコンと経過表示を切り替え")
                .animation(.easeInOut(duration: 0.35), value: showLastBowelStats)
                
                Button {
                    AppAnalytics.log(.sheet_open_record_input, parameters: ["source": "home"])
                    showRecordInput = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                        Text("お通じを入力")
                            .fontWeight(.medium)
                    }
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(AppColors.accentPink)
                    .clipShape(Capsule())
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 32)
    }
    
    // MARK: - 薬の追加セクション
    private var addMedicineSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(AppColors.border)
                .frame(height: 1)
                .padding(.horizontal, 24)
            
            Button {
                AppAnalytics.log(.sheet_open_medicine_input, parameters: ["source": "home_add_section"])
                editingMedication = nil
                showMedicineInput = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "plus.circle.fill")
                    Text("薬を追加")
                }
                .font(.subheadline)
                .foregroundStyle(AppColors.accentPink)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(AppColors.pastelPink.opacity(0.3))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
        }
    }
    
}

#Preview {
    HomeView()
        .environment(DataStore.shared)
        .environment(BowelConditionColorSettings.shared)
}
