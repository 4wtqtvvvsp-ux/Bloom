//
//  ReviewPromptManager.swift
//  うんち記録
//
//  お通じ保存後のレビュー案内（頻度・フラグ管理）
//

import Foundation
import UIKit

enum ReviewPromptManager {
    private enum Key {
        static let completed = "reviewPrompt.completed"
        static let saveCount = "reviewPrompt.saveCount"
        static let lastPromptSaveCount = "reviewPrompt.lastPromptSaveCount"
        static let dislikeUntil = "reviewPrompt.dislikeUntil"
    }

    /// App Store「レビューを書く」画面
    static let writeReviewURL = URL(string: "https://apps.apple.com/app/id6762580003?action=write-review")!

    /// 初めて案内するまでの最低保存回数
    private static let minimumSavesBeforePrompt = 3
    /// 案内を出してから次まで空ける保存回数（「まだわからない」後など）
    private static let savesBetweenPrompts = 5
    /// 表示確率（1/5 = 20%）
    private static let promptChanceDenominator = 5
    /// 「いまいち」後の再表示までの日数
    private static let dislikeCooldownDays = 30

    private static var defaults: UserDefaults { .standard }

    static var hasCompletedReviewFlow: Bool {
        defaults.bool(forKey: Key.completed)
    }

    /// 保存成功時に呼ぶ（カウントだけ進める）
    static func noteSuccessfulSave() {
        let count = defaults.integer(forKey: Key.saveCount) + 1
        defaults.set(count, forKey: Key.saveCount)
    }

    /// 今回の保存後に案内を出すか
    static func shouldShowPrompt() -> Bool {
        if hasCompletedReviewFlow { return false }

        if let until = defaults.object(forKey: Key.dislikeUntil) as? Date, Date() < until {
            return false
        }

        let saveCount = defaults.integer(forKey: Key.saveCount)
        guard saveCount >= minimumSavesBeforePrompt else { return false }

        let lastPrompt = defaults.integer(forKey: Key.lastPromptSaveCount)
        guard saveCount - lastPrompt >= savesBetweenPrompts || lastPrompt == 0 else { return false }

        // 初回候補（lastPrompt == 0）でも確率をかける。最低回数到達後の各候補で抽選
        return Int.random(in: 1...promptChanceDenominator) == 1
    }

    static func markPromptShown() {
        defaults.set(defaults.integer(forKey: Key.saveCount), forKey: Key.lastPromptSaveCount)
    }

    /// 「はい」→ App Store へ。以降は出さない
    static func handleLiked() {
        markPromptShown()
        defaults.set(true, forKey: Key.completed)
        UIApplication.shared.open(writeReviewURL)
    }

    /// 「いまいち」→ しばらく出さない
    static func handleDisliked() {
        markPromptShown()
        let until = Calendar.current.date(byAdding: .day, value: dislikeCooldownDays, to: Date()) ?? Date()
        defaults.set(until, forKey: Key.dislikeUntil)
    }

    /// 「まだわからない」→ また後で出る
    static func handleNotSure() {
        markPromptShown()
    }
}
