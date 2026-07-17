//
//  MyLikedMenuRemoteDataSource.swift
//  Siksha
//
//  Created by Codex on 6/24/26.
//

import Alamofire
import Foundation

protocol MyLikedMenuRemoteDataSource {
    func fetchMyLikedMenus() async throws -> MyLikedMenuResponseDTO
    func enableMenuAlarm(menuId: Int) async throws
    func disableMenuAlarm(menuId: Int) async throws
    func enableAllMenuAlarms() async throws
    func disableAllMenuAlarms() async throws
    func fetchAlarmTime() async throws -> AlarmTimeResponseDTO
    func updateAlarmTime(_ alarmTime: AlarmTime) async throws
}

final class MyLikedMenuRemoteDataSourceImpl: MyLikedMenuRemoteDataSource {
    func fetchMyLikedMenus() async throws -> MyLikedMenuResponseDTO {
        try await AF
            .request(SikshaAPI.getMyLikedMenu)
            .validate()
            .serializingDecodable(MyLikedMenuResponseDTO.self)
            .value
    }

    func enableMenuAlarm(menuId: Int) async throws {
        try await validateNoContentRequest(AF.request(SikshaAPI.alarmOn(menuId: menuId)))
    }

    func disableMenuAlarm(menuId: Int) async throws {
        try await validateNoContentRequest(AF.request(SikshaAPI.alarmOff(menuId: menuId)))
    }

    func enableAllMenuAlarms() async throws {
        try await validateNoContentRequest(AF.request(SikshaAPI.alarmOnAll))
    }

    func disableAllMenuAlarms() async throws {
        try await validateNoContentRequest(AF.request(SikshaAPI.alarmOffAll))
    }

    func fetchAlarmTime() async throws -> AlarmTimeResponseDTO {
        try await AF
            .request(SikshaAPI.getAlarmTime)
            .validate()
            .serializingDecodable(AlarmTimeResponseDTO.self)
            .value
    }

    func updateAlarmTime(_ alarmTime: AlarmTime) async throws {
        try await validateNoContentRequest(AF.request(SikshaAPI.setAlarmTime(alarmTime: alarmTime.rawValue)))
    }

    private func validateNoContentRequest(_ request: DataRequest) async throws {
        _ =
            try await request
            .validate()
            .serializingData(emptyResponseCodes: [200, 201, 204])
            .value
    }
}
