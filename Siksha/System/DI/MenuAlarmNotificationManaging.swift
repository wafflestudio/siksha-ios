//
//  MenuAlarmNotificationManaging.swift
//  Siksha
//
//  Created by Codex on 6/30/26.
//

protocol MenuAlarmNotificationManaging {
    func requestAuthorization() async -> Bool
    func registerRemoteNotificationsIfNeeded()
}
