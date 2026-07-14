//
//  MenuAlarmNotificationManaging.swift
//  Siksha
//
//  Created by Codex on 6/30/26.
//

import Foundation

protocol MenuAlarmNotificationManaging {
    func requestAuthorization() async -> Bool
    @MainActor
    func registerRemoteNotificationsIfNeeded()
    @MainActor
    func didRegisterForRemoteNotifications(with deviceToken: Data)
    @MainActor
    func didFailToRegisterForRemoteNotifications(error: Error)
}
