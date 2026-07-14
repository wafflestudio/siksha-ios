//
//  DeviceTokenLocalDataSource.swift
//  Siksha
//
//  Created by Codex on 7/13/26.
//

import Foundation

protocol DeviceTokenLocalDataSource {
    func loadToken() -> String?
    func saveToken(_ token: String)
    func isRegistered() -> Bool
    func setRegistered(_ isRegistered: Bool)
    func clear()
}

final class UserDefaultsDeviceTokenLocalDataSource: DeviceTokenLocalDataSource {
    private enum Key {
        static let token = "fcmToken"
        static let isRegistered = "alreadySentFCM"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadToken() -> String? {
        userDefaults.string(forKey: Key.token)
    }

    func saveToken(_ token: String) {
        if loadToken() != token {
            userDefaults.set(false, forKey: Key.isRegistered)
        }
        userDefaults.set(token, forKey: Key.token)
    }

    func isRegistered() -> Bool {
        userDefaults.bool(forKey: Key.isRegistered)
    }

    func setRegistered(_ isRegistered: Bool) {
        userDefaults.set(isRegistered, forKey: Key.isRegistered)
    }

    func clear() {
        userDefaults.removeObject(forKey: Key.token)
        userDefaults.removeObject(forKey: Key.isRegistered)
    }
}
