//
//  RegisterUserDeviceUseCase.swift
//  Siksha
//
//  Created by Codex on 7/13/26.
//

protocol RegisterUserDeviceUseCase {
    func execute(fcmToken: String) async throws
}

final class DefaultRegisterUserDeviceUseCase: RegisterUserDeviceUseCase {
    private let lifecycle: DeviceTokenLifecycle

    init(lifecycle: DeviceTokenLifecycle) {
        self.lifecycle = lifecycle
    }

    func execute(fcmToken: String) async throws {
        try await lifecycle.register(fcmToken: fcmToken)
    }
}
