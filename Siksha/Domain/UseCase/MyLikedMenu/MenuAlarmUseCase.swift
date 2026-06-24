//
//  MenuAlarmUseCase.swift
//  Siksha
//
//  Created by Codex on 6/24/26.
//

protocol MenuAlarmUseCase {
    func getAlarmEnabled() -> Bool
    func setAlarmEnabled(_ enabled: Bool)
    func enableMenuAlarm(menuId: Int) async throws
    func disableMenuAlarm(menuId: Int) async throws
    func enableAllMenuAlarms() async throws
    func disableAllMenuAlarms() async throws
    func fetchAlarmTime() async throws -> AlarmTime
    func updateAlarmTime(_ alarmTime: AlarmTime) async throws
}

final class DefaultMenuAlarmUseCase: MenuAlarmUseCase {
    private let repository: MyLikedMenuRepositoryProtocol
    
    init(repository: MyLikedMenuRepositoryProtocol) {
        self.repository = repository
    }
    
    func getAlarmEnabled() -> Bool {
        repository.getAlarmEnabled()
    }
    
    func setAlarmEnabled(_ enabled: Bool) {
        repository.setAlarmEnabled(enabled)
    }
    
    func enableMenuAlarm(menuId: Int) async throws {
        try await repository.enableMenuAlarm(menuId: menuId)
    }
    
    func disableMenuAlarm(menuId: Int) async throws {
        try await repository.disableMenuAlarm(menuId: menuId)
    }
    
    func enableAllMenuAlarms() async throws {
        try await repository.enableAllMenuAlarms()
        repository.setAlarmEnabled(true)
    }
    
    func disableAllMenuAlarms() async throws {
        try await repository.disableAllMenuAlarms()
        repository.setAlarmEnabled(false)
    }
    
    func fetchAlarmTime() async throws -> AlarmTime {
        try await repository.fetchAlarmTime()
    }
    
    func updateAlarmTime(_ alarmTime: AlarmTime) async throws {
        try await repository.updateAlarmTime(alarmTime)
    }
}
