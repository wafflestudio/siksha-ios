//
//  MyLikedMenuRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 6/24/26.
//

protocol MyLikedMenuRepositoryProtocol {
    func fetchMyLikedMenus() async throws -> [RestaurantLikedMenuGroup]
    func enableMenuAlarm(menuId: Int) async throws
    func disableMenuAlarm(menuId: Int) async throws
    func enableAllMenuAlarms() async throws
    func disableAllMenuAlarms() async throws
    func fetchAlarmTime() async throws -> AlarmTime
    func updateAlarmTime(_ alarmTime: AlarmTime) async throws
    func getAlarmEnabled() -> Bool
    func setAlarmEnabled(_ enabled: Bool)
}
