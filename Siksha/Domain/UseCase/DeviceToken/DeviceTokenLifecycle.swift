//
//  DeviceTokenLifecycle.swift
//  Siksha
//
//  Created by Codex on 7/13/26.
//

private struct DeviceTokenSnapshot {
    let token: String
}

struct DeviceTokenLifecycleOperationFailure: Error {
    let operationError: Error
    let deviceRestorationError: Error?
}

protocol DeviceTokenLifecycle {
    func register(fcmToken: String) async throws
    func unregisterCurrent() async throws

    func performWithCurrentDeviceUnregistered<T>(
        _ operation: () async throws -> T
    ) async throws -> T
}

final class DefaultDeviceTokenLifecycle: DeviceTokenLifecycle {
    private let deviceTokenRepository: DeviceTokenRepositoryProtocol
    private let authRepository: AuthRepositoryProtocol
    private let operationGate: DeviceTokenOperationGate

    init(
        deviceTokenRepository: DeviceTokenRepositoryProtocol,
        authRepository: AuthRepositoryProtocol,
        operationGate: DeviceTokenOperationGate = DeviceTokenOperationGate()
    ) {
        self.deviceTokenRepository = deviceTokenRepository
        self.authRepository = authRepository
        self.operationGate = operationGate
    }

    func register(fcmToken: String) async throws {
        try await operationGate.withExclusiveAccess {
            guard self.authRepository.loadSession() != nil else {
                return
            }

            try await self.registerDevice(fcmToken: fcmToken)
        }
    }

    func unregisterCurrent() async throws {
        try await operationGate.withExclusiveAccess {
            _ = try await self.unregisterCurrentDevice()
        }
    }

    func performWithCurrentDeviceUnregistered<T>(
        _ operation: () async throws -> T
    ) async throws -> T {
        try await operationGate.withExclusiveAccess {
            let snapshot = try await self.unregisterCurrentDevice()

            do {
                return try await operation()
            } catch let operationError {
                var deviceRestorationError: Error?

                if let snapshot {
                    do {
                        try await self.restoreDevice(snapshot)
                    } catch {
                        deviceRestorationError = error
                    }
                }

                throw DeviceTokenLifecycleOperationFailure(
                    operationError: operationError,
                    deviceRestorationError: deviceRestorationError
                )
            }
        }
    }

    private func registerDevice(fcmToken: String) async throws {
        let storedToken = deviceTokenRepository.loadDeviceToken()
        let isRegistered = deviceTokenRepository.isDeviceTokenRegistered()

        if storedToken == fcmToken, isRegistered {
            return
        }

        if let storedToken {
            try await deviceTokenRepository.unregisterDevice(fcmToken: storedToken)
        }

        deviceTokenRepository.saveDeviceToken(fcmToken)
        deviceTokenRepository.setDeviceTokenRegistered(false)

        do {
            try await deviceTokenRepository.registerDevice(fcmToken: fcmToken)
            deviceTokenRepository.setDeviceTokenRegistered(true)
        } catch {
            deviceTokenRepository.setDeviceTokenRegistered(false)
            throw error
        }
    }

    private func unregisterCurrentDevice() async throws -> DeviceTokenSnapshot? {
        guard let token = deviceTokenRepository.loadDeviceToken() else {
            return nil
        }

        try await deviceTokenRepository.unregisterDevice(fcmToken: token)
        deviceTokenRepository.setDeviceTokenRegistered(false)
        return DeviceTokenSnapshot(token: token)
    }

    private func restoreDevice(_ snapshot: DeviceTokenSnapshot) async throws {
        deviceTokenRepository.saveDeviceToken(snapshot.token)
        deviceTokenRepository.setDeviceTokenRegistered(false)

        do {
            try await deviceTokenRepository.registerDevice(fcmToken: snapshot.token)
            deviceTokenRepository.setDeviceTokenRegistered(true)
        } catch {
            deviceTokenRepository.setDeviceTokenRegistered(false)
            throw error
        }
    }
}
