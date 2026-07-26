//
//  MenuAlarmNotificationManaging.swift
//  Siksha
//
//  Created by Codex on 6/30/26.
//

import Foundation

@MainActor
protocol MenuAlarmNotificationManaging {
    func requestAuthorization() async -> Bool
    func registerRemoteNotificationsIfNeeded()
    func didRegisterForRemoteNotifications(with deviceToken: Data)
    func didFailToRegisterForRemoteNotifications(error: Error)
}
