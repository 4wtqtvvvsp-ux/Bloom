//
//  FirebaseBootstrap.swift
//  うんち記録
//
//  configure() は1回だけ。FirebaseApp.app() を configure 前に呼ばない（I-COR000003 防止）。
//

import Foundation
import FirebaseCore

enum FirebaseBootstrap {
    private static let lock = NSLock()
    private(set) static var didConfigure = false

    static func configureIfNeeded() {
        lock.lock()
        defer { lock.unlock() }
        guard !didConfigure else { return }
        guard Bundle.main.url(forResource: "GoogleService-Info", withExtension: "plist") != nil else { return }
        FirebaseApp.configure()
        didConfigure = true
    }
}
