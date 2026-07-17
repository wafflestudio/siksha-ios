//
//  DeviceTokenRepositoryImpl.swift
//  Siksha
//
//  Created by Codex on 7/13/26.
//

final class DeviceTokenRepositoryImpl: DeviceTokenRepositoryProtocol {
    private let remote: DeviceTokenRemoteDataSource
    private let local: DeviceTokenLocalDataSource

    init(
        remote: DeviceTokenRemoteDataSource,
        local: DeviceTokenLocalDataSource
    ) {
        self.remote = remote
        self.local = local
    }

    func registerDevice(fcmToken: String) async throws {
        try await remote.register(fcmToken: fcmToken)
    }

    func unregisterDevice(fcmToken: String) async throws {
        try await remote.unregister(fcmToken: fcmToken)
    }

    func loadDeviceToken() -> String? {
        local.loadToken()
    }

    func saveDeviceToken(_ token: String) {
        local.saveToken(token)
    }

    func isDeviceTokenRegistered() -> Bool {
        local.isRegistered()
    }

    func setDeviceTokenRegistered(_ isRegistered: Bool) {
        local.setRegistered(isRegistered)
    }

    func clearDeviceToken() {
        local.clear()
    }
}
