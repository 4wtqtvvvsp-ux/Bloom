//
//  BloomAppDelegate.swift
//  うんち記録
//
//  Firebase 初期化（SwiftUI より前に実行するため UIApplicationDelegate を使用）
//

import UIKit

final class BloomAppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseBootstrap.configureIfNeeded()
        #if DEBUG
        let args = ProcessInfo.processInfo.arguments
        let debugOn = args.contains("-FIRDebugEnabled")
        print("[Firebase] -FIRDebugEnabled (DebugView 必須): \(debugOn)")
        if !debugOn {
            print("[Firebase] ★ 左の「+」で -FIRDebugEnabled を追加し、チェックを ON にしてください（共有スキームを使う場合も Run を開いて確認）。")
        }
        #endif
        return true
    }
}
