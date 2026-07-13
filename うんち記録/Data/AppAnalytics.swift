//
//  AppAnalytics.swift
//  うんち記録
//
//  Firebase Analytics（GoogleService-Info 未配置時は no-op）
//

import FirebaseAnalytics
import FirebaseCore

enum AppAnalytics {
    /// 送信イベント名はローマ字（Firebase は英数字とアンダースコアのみ可）
    enum Name: String {
        case app_launch = "app_Kidou"

        case tab_home = "tab_Hoomu"
        case tab_calendar = "tab_Karendaa"
        case tab_settings = "tab_Settei"

        case home_medication_header_tap = "home_KusuriJouhouTabu"
        case home_stats_center_tap = "home_ChushinTabu"
        case sheet_open_record_input = "shito_OtuujiNyuryoku"
        case sheet_open_medicine_list = "shito_KusuriIchiran"
        case sheet_open_medicine_input = "shito_KusuriNyuryoku"

        case medicine_list_row_tap = "kusuriIchiran_GyouTabu"
        case medicine_list_add_tap = "kusuriIchiran_TsuikaTabu"
        case medicine_list_close_tap = "kusuriIchiran_ShimeruTabu"

        case medicine_input_cancel = "kusuriNyuryoku_Torikeshi"
        case medicine_input_save = "kusuriNyuryoku_Hozon"
        case medicine_input_stop_taking_dialog = "kusuriNyuryoku_YameruKakuninHyoji"
        case medicine_input_stop_taking_confirm = "kusuriNyuryoku_YameruKakutei"

        case record_input_cancel = "otuujiNyuryoku_Torikeshi"
        case record_input_save = "otuujiNyuryoku_Hozon"
        case record_input_select_condition = "otuujiNyuryoku_ChoushiSentaku"
        case record_input_select_amount = "otuujiNyuryoku_RyouSentaku"
        case record_input_photo_add_tap = "otuujiNyuryoku_ShashinTsuikaTabu"
        case record_input_photo_source_camera = "otuujiNyuryoku_ShashinKamera"
        case record_input_photo_source_library = "otuujiNyuryoku_ShashinRaiburari"
        case record_input_photo_remove_tap = "otuujiNyuryoku_ShashinSakujoTabu"
        case record_input_medication_toggle = "otuujiNyuryoku_KusuriKirikae"

        case record_edit_cancel = "otuujiShusei_Torikeshi"
        case record_edit_save = "otuujiShusei_Hozon"
        case record_edit_select_condition = "otuujiShusei_ChoushiSentaku"
        case record_edit_select_amount = "otuujiShusei_RyouSentaku"
        case record_edit_photo_add_tap = "otuujiShusei_ShashinTsuikaTabu"
        case record_edit_photo_source_camera = "otuujiShusei_ShashinKamera"
        case record_edit_photo_source_library = "otuujiShusei_ShashinRaiburari"
        case record_edit_photo_remove_tap = "otuujiShusei_ShashinSakujoTabu"
        case record_edit_delete_tap = "otuujiShusei_SakujoTabu"
        case record_edit_delete_confirm = "otuujiShusei_SakujoKakutei"
        case record_edit_delete_cancel = "otuujiShusei_SakujoTorikeshi"

        case day_detail_toolbar_close = "hibetuShousai_JoubuShimeru"
        case day_detail_toolbar_save = "hibetuShousai_JoubuHozon"
        case day_detail_add_record_tap = "hibetuShousai_TsuikaTabu"
        case day_detail_open_record_edit = "hibetuShousai_ShuseiKaishi"
        case day_detail_medication_draft_toggle = "hibetuShousai_KusuriRasutoKirikae"

        case calendar_month_prev = "karendaa_Zengetsu"
        case calendar_month_next = "karendaa_Jigetsu"
        case calendar_day_tap = "karendaa_HiTabu"
        case calendar_medication_legend_long_press = "karendaa_KusuriSetsumeiNagoshi"
        case calendar_medication_delete_cancel = "karendaa_KusuriSakujoTorikeshi"
        case calendar_medication_delete_confirm = "karendaa_KusuriSakujoKakutei"

        case screen_condition_icon_color = "gamen_ChoushiAikonIro"
        case settings_icon_color_reset = "settei_AikonIroRisetto"
        case settings_lock_toggle_on = "settei_RokkuOn"
        case settings_lock_toggle_off_confirm = "settei_RokkuOffKakunin"
        case settings_lock_toggle_off_execute = "settei_RokkuOffJikkou"
        case settings_lock_toggle_off_cancel = "settei_RokkuOffTorikeshi"

        case pin_setup_cancel = "pinSettoi_Torikeshi"
        case pin_setup_proceed_step1 = "pinSettoi_Tugi"
        case pin_setup_complete = "pinSettoi_Kanryou"

        case lock_unlock_success = "rokkuKaijoSeikou"
        case lock_unlock_fail = "rokkuKaijoShippai"

        case app_lock_on_background = "app_HaikeiDeRokku"

        case image_picker_cancel = "gazouSentaku_Torikeshi"
    }

    static func log(_ name: Name, parameters: [String: String]? = nil) {
        log(name.rawValue, parameters: parameters)
    }

    static func log(_ name: String, parameters: [String: String]? = nil) {
        guard FirebaseApp.app() != nil else { return }
        let mapped: [String: Any]? = parameters.map { dict in
            Dictionary(uniqueKeysWithValues: dict.map { ($0.key, $0.value as Any) })
        }
        Analytics.logEvent(name, parameters: mapped)
    }
}
