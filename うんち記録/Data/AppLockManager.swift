//
//  AppLockManager.swift
//  うんち記録
//
//  4桁パスワードロック（PIN は Keychain に保存）
//

import Foundation
import Security

@Observable
final class AppLockManager {
    static let shared = AppLockManager()
    
    private let enabledKey = "app_lock_enabled"
    private let keychainService = "Bloom.appLock.pin"
    private let keychainAccount = "pin"
    
    /// 設定の「パスワード」がオンか
    var isLockEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: enabledKey) }
        set { UserDefaults.standard.set(newValue, forKey: enabledKey) }
    }
    
    /// 直近までロック解除済みか（バックグラウンドで false に戻す）
    var isUnlocked = true
    
    private init() {
        if isLockEnabled && pinFromKeychain() == nil {
            UserDefaults.standard.set(false, forKey: enabledKey)
        }
        if isLockEnabled && pinFromKeychain() != nil {
            isUnlocked = false
        } else {
            isUnlocked = true
        }
    }
    
    func lockIfEnabled() {
        guard isLockEnabled, pinFromKeychain() != nil else { return }
        isUnlocked = false
    }
    
    func savePINAndEnable(_ pin: String) {
        guard pin.count == 4, pin.allSatisfy(\.isNumber) else { return }
        saveToKeychain(pin)
        isLockEnabled = true
        isUnlocked = true
    }
    
    func verifyPIN(_ pin: String) -> Bool {
        guard let stored = pinFromKeychain() else { return false }
        return pin == stored
    }
    
    func unlock() {
        isUnlocked = true
    }
    
    func disableLock() {
        isLockEnabled = false
        deleteKeychainPIN()
        isUnlocked = true
    }
    
    // MARK: - Keychain
    
    private func saveToKeychain(_ pin: String) {
        deleteKeychainPIN()
        let data = Data(pin.utf8)
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        SecItemAdd(query as CFDictionary, nil)
    }
    
    private func pinFromKeychain() -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    private func deleteKeychainPIN() {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        SecItemDelete(query as CFDictionary)
    }
}
