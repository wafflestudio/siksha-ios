//
//  LogoutUseCase.swift
//  Siksha
//
//  Created by Codex on 7/13/26.
//

protocol LogoutUseCase {
    func execute() async throws
}

final class DefaultLogoutUseCase: LogoutUseCase {
    private let deviceTokenLifecycle: DeviceTokenLifecycle
    private let accountLocalStateCleaner: AccountLocalStateCleaner

    init(
        deviceTokenLifecycle: DeviceTokenLifecycle,
        accountLocalStateCleaner: AccountLocalStateCleaner
    ) {
        self.deviceTokenLifecycle = deviceTokenLifecycle
        self.accountLocalStateCleaner = accountLocalStateCleaner
    }

    func execute() async throws {
        try await deviceTokenLifecycle.performWithCurrentDeviceUnregistered {
            await self.accountLocalStateCleaner.execute()
        }
    }
}
