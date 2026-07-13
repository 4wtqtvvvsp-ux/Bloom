# Bloom（うんち記録）Analytics カスタムイベント一覧

Firebase に送信している **カスタムイベント名**（ローマ字）と、コード上の識別子の対応です。  
（`user_engagement` など **SDK が自動で送るイベント**はこの表に含みません。）

| コード（Swift `AppAnalytics.Name`） | Firebase イベント名（ローマ字） | 意味（操作の概要） |
|-----------------------------------|----------------------------------|----------------------|
| `app_launch` | `app_Kidou` | アプリ起動直後（1回） |
| `tab_home` | `tab_Hoomu` | タブ：ホーム |
| `tab_calendar` | `tab_Karendaa` | タブ：カレンダー |
| `tab_settings` | `tab_Settei` | タブ：設定 |
| `home_medication_header_tap` | `home_KusuriJouhouTabu` | ホーム：服用中の薬エリアをタップ |
| `home_stats_center_tap` | `home_ChushinTabu` | ホーム：中央（うさぎ／経過表示）をタップ |
| `sheet_open_record_input` | `shito_OtuujiNyuryoku` | お通じ入力シートを開く（`source` パラメータあり） |
| `sheet_open_medicine_list` | `shito_KusuriIchiran` | 服用中の薬一覧シートを開く |
| `sheet_open_medicine_input` | `shito_KusuriNyuryoku` | 薬の追加・編集シートを開く（`source` あり） |
| `medicine_list_row_tap` | `kusuriIchiran_GyouTabu` | 薬一覧：行をタップ |
| `medicine_list_add_tap` | `kusuriIchiran_TsuikaTabu` | 薬一覧：薬を追加 |
| `medicine_list_close_tap` | `kusuriIchiran_ShimeruTabu` | 薬一覧：閉じる |
| `medicine_input_cancel` | `kusuriNyuryoku_Torikeshi` | 薬入力：キャンセル |
| `medicine_input_save` | `kusuriNyuryoku_Hozon` | 薬入力：保存（`mode`: new/edit） |
| `medicine_input_stop_taking_dialog` | `kusuriNyuryoku_YameruKakuninHyoji` | 薬入力：服用をやめる確認を出す |
| `medicine_input_stop_taking_confirm` | `kusuriNyuryoku_YameruKakutei` | 薬入力：服用をやめる確定 |
| `record_input_cancel` | `otuujiNyuryoku_Torikeshi` | お通じ入力：キャンセル |
| `record_input_save` | `otuujiNyuryoku_Hozon` | お通じ入力：保存 |
| `record_input_select_condition` | `otuujiNyuryoku_ChoushiSentaku` | お通じ入力：調子（硬さ）を選択 |
| `record_input_select_amount` | `otuujiNyuryoku_RyouSentaku` | お通じ入力：量を選択 |
| `record_input_photo_add_tap` | `otuujiNyuryoku_ShashinTsuikaTabu` | お通じ入力：写真追加ボタン |
| `record_input_photo_source_camera` | `otuujiNyuryoku_ShashinKamera` | お通じ入力：カメラを選ぶ |
| `record_input_photo_source_library` | `otuujiNyuryoku_ShashinRaiburari` | お通じ入力：ライブラリを選ぶ |
| `record_input_photo_remove_tap` | `otuujiNyuryoku_ShashinSakujoTabu` | お通じ入力：写真を削除 |
| `record_input_medication_toggle` | `otuujiNyuryoku_KusuriKirikae` | お通じ入力：その日の服用チェック切替 |
| `record_edit_cancel` | `otuujiShusei_Torikeshi` | 記録編集：キャンセル |
| `record_edit_save` | `otuujiShusei_Hozon` | 記録編集：保存 |
| `record_edit_select_condition` | `otuujiShusei_ChoushiSentaku` | 記録編集：調子を選択 |
| `record_edit_select_amount` | `otuujiShusei_RyouSentaku` | 記録編集：量を選択 |
| `record_edit_photo_add_tap` | `otuujiShusei_ShashinTsuikaTabu` | 記録編集：写真追加 |
| `record_edit_photo_source_camera` | `otuujiShusei_ShashinKamera` | 記録編集：カメラ |
| `record_edit_photo_source_library` | `otuujiShusei_ShashinRaiburari` | 記録編集：ライブラリ |
| `record_edit_photo_remove_tap` | `otuujiShusei_ShashinSakujoTabu` | 記録編集：写真削除 |
| `record_edit_delete_tap` | `otuujiShusei_SakujoTabu` | 記録編集：削除ボタン |
| `record_edit_delete_confirm` | `otuujiShusei_SakujoKakutei` | 記録編集：削除確定 |
| `record_edit_delete_cancel` | `otuujiShusei_SakujoTorikeshi` | 記録編集：削除キャンセル |
| `day_detail_toolbar_close` | `hibetuShousai_JoubuShimeru` | 日別詳細：閉じる |
| `day_detail_toolbar_save` | `hibetuShousai_JoubuHozon` | 日別詳細：保存（服用ドラフト） |
| `day_detail_add_record_tap` | `hibetuShousai_TsuikaTabu` | 日別詳細：お通じを追加 |
| `day_detail_open_record_edit` | `hibetuShousai_ShuseiKaishi` | 日別詳細：記録行タップで編集へ |
| `day_detail_medication_draft_toggle` | `hibetuShousai_KusuriRasutoKirikae` | 日別詳細：服用チェック（ドラフト） |
| `calendar_month_prev` | `karendaa_Zengetsu` | カレンダー：前の月 |
| `calendar_month_next` | `karendaa_Jigetsu` | カレンダー：次の月 |
| `calendar_day_tap` | `karendaa_HiTabu` | カレンダー：日付セルタップ |
| `calendar_medication_legend_long_press` | `karendaa_KusuriSetsumeiNagoshi` | カレンダー：薬凡例の長押し |
| `calendar_medication_delete_cancel` | `karendaa_KusuriSakujoTorikeshi` | カレンダー：薬削除アラート取消 |
| `calendar_medication_delete_confirm` | `karendaa_KusuriSakujoKakutei` | カレンダー：薬削除確定 |
| `screen_condition_icon_color` | `gamen_ChoushiAikonIro` | 設定：調子アイコン色の画面表示 |
| `settings_icon_color_reset` | `settei_AikonIroRisetto` | 設定：アイコン色をデフォルトに戻す |
| `settings_lock_toggle_on` | `settei_RokkuOn` | 設定：パスワード ON |
| `settings_lock_toggle_off_confirm` | `settei_RokkuOffKakunin` | 設定：パスワード OFF 確認ダイアログで実行 |
| `settings_lock_toggle_off_execute` | `settei_RokkuOffJikkou` | 設定：パスワード OFF 実行 |
| `settings_lock_toggle_off_cancel` | `settei_RokkuOffTorikeshi` | 設定：パスワード OFF キャンセル |
| `pin_setup_cancel` | `pinSettoi_Torikeshi` | PIN 設定：キャンセル |
| `pin_setup_proceed_step1` | `pinSettoi_Tugi` | PIN 設定：1 段目から次へ |
| `pin_setup_complete` | `pinSettoi_Kanryou` | PIN 設定：完了 |
| `lock_unlock_success` | `rokkuKaijoSeikou` | ロック画面：解除成功 |
| `lock_unlock_fail` | `rokkuKaijoShippai` | ロック画面：解除失敗 |
| `app_lock_on_background` | `app_HaikeiDeRokku` | アプリがバックグラウンドへ（ロック有効時） |
| `image_picker_cancel` | `gazouSentaku_Torikeshi` | 画像ピッカー：キャンセル（`source`: camera/library） |

## 補足：`user_engagement` とは

**Google Analytics（Firebase Analytics）が自動で記録する標準イベント**のひとつです。アプリに **`user_engagement` という名前のイベントを書いたわけではありません。**

- **何を表すか**: ユーザーがアプリを前面で使っている間の「エンゲージメント（関与）」の区間を表すイベントです。セッションや滞在の分析に使われます。
- **いつ出るか**: SDK がバックグラウンド／前面の切り替えやタイマーに応じて、一定のルールで自動送信されます。
- **カスタムイベントとの違い**: `app_Kidou` や `tab_Hoomu` は **アプリ側で明示的に `logEvent` したカスタムイベント**です。`user_engagement` は **計測基盤側の自動イベント**です。

定義の詳細は [GA4 自動収集のイベント](https://support.google.com/analytics/answer/9234069)（Google ヘルプ）を参照してください。
