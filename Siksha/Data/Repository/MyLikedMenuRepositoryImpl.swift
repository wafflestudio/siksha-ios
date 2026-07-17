//
//  MyLikedMenuRepositoryImpl.swift
//  Siksha
//
//  Created by Codex on 6/24/26.
//

import Foundation

final class MyLikedMenuRepositoryImpl: MyLikedMenuRepositoryProtocol, MenuAlarmPreferenceRepositoryProtocol {
    private let remote: MyLikedMenuRemoteDataSource
    private let local: MenuAlarmLocalDataSource

    init(
        remote: MyLikedMenuRemoteDataSource,
        local: MenuAlarmLocalDataSource
    ) {
        self.remote = remote
        self.local = local
    }

    func fetchMyLikedMenus() async throws -> [RestaurantLikedMenuGroup] {
        try await remote.fetchMyLikedMenus().toDomain()
    }

    func enableMenuAlarm(menuId: Int) async throws {
        try await remote.enableMenuAlarm(menuId: menuId)
    }

    func disableMenuAlarm(menuId: Int) async throws {
        try await remote.disableMenuAlarm(menuId: menuId)
    }

    func enableAllMenuAlarms() async throws {
        try await remote.enableAllMenuAlarms()
    }

    func disableAllMenuAlarms() async throws {
        try await remote.disableAllMenuAlarms()
    }

    func fetchAlarmTime() async throws -> AlarmTime {
        let alarmType = try await remote.fetchAlarmTime().alarmType
        return AlarmTime(rawValue: alarmType) ?? .DAILY
    }

    func updateAlarmTime(_ alarmTime: AlarmTime) async throws {
        try await remote.updateAlarmTime(alarmTime)
    }

    func getAlarmEnabled() -> Bool {
        local.getAlarmEnabled()
    }

    func setAlarmEnabled(_ enabled: Bool) {
        local.setAlarmEnabled(enabled)
    }
}

private extension MyLikedMenuResponseDTO {
    func toDomain() -> [RestaurantLikedMenuGroup] {
        groups.map { $0.toDomain() }
    }
}

private extension RestaurantLikedMenuGroupDTO {
    func toDomain() -> RestaurantLikedMenuGroup {
        RestaurantLikedMenuGroup(
            id: id,
            name: name,
            menus: menus.map { $0.toDomain() }
        )
    }
}

private extension MyLikedMenuDTO {
    func toDomain() -> MyLikedMenu {
        MyLikedMenu(
            id: id,
            code: code,
            nameKr: nameKr,
            nameEn: nameEn,
            price: price,
            score: score,
            reviewCnt: reviewCount,
            isLiked: isLiked,
            likeCnt: likeCount,
            etc: etc,
            alarm: alarm
        )
    }
}
