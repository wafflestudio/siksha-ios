//
//  MenuAlarmLocalDataSource.swift
//  Siksha
//
//  Created by Codex on 6/24/26.
//

import Foundation

protocol MenuAlarmLocalDataSource {
    func getAlarmEnabled() -> Bool
    func setAlarmEnabled(_ enabled: Bool)
}

final class UserDefaultsMenuAlarmLocalDataSource: MenuAlarmLocalDataSource {
    private let userDefaults: UserDefaults
    private let alarmEnabledKey = "isAlarmEnabled"
    
    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }
    
    func getAlarmEnabled() -> Bool {
        userDefaults.bool(forKey: alarmEnabledKey)
    }
    
    func setAlarmEnabled(_ enabled: Bool) {
        userDefaults.set(enabled, forKey: alarmEnabledKey)
    }
}
