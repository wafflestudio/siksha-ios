//
//  DeviceTokenUseCaseTests.swift
//  SikshaTests
//
//  Created by Codex on 7/13/26.
//

import XCTest

@testable import Siksha

final class DeviceTokenUseCaseTests: XCTestCase {
    func testRegisterWithoutSessionSkipsLocalAndRemoteWork() async throws {
        let repository = DeviceTokenRepositorySpy()
        let useCase = makeRegisterUseCase(repository: repository, hasSession: false)

        try await useCase.execute(fcmToken: "new-token")

        XCTAssertNil(repository.token)
        XCTAssertTrue(repository.remoteEvents.isEmpty)
    }

    func testRegisterSameRegisteredTokenSkipsRemoteWork() async throws {
        let repository = DeviceTokenRepositorySpy(token: "token", isRegistered: true)
        let useCase = makeRegisterUseCase(repository: repository)

        try await useCase.execute(fcmToken: "token")

        XCTAssertTrue(repository.remoteEvents.isEmpty)
        XCTAssertTrue(repository.isRegistered)
    }

    func testRegisterSameUnconfirmedTokenDeletesThenPosts() async throws {
        let repository = DeviceTokenRepositorySpy(token: "token", isRegistered: false)
        let useCase = makeRegisterUseCase(repository: repository)

        try await useCase.execute(fcmToken: "token")

        XCTAssertEqual(repository.remoteEvents, ["delete:token", "post:token"])
        XCTAssertTrue(repository.isRegistered)
    }

    func testRegisterChangedTokenDeletesOldTokenBeforePostingNewToken() async throws {
        let repository = DeviceTokenRepositorySpy(token: "old-token", isRegistered: true)
        let useCase = makeRegisterUseCase(repository: repository)

        try await useCase.execute(fcmToken: "new-token")

        XCTAssertEqual(repository.remoteEvents, ["delete:old-token", "post:new-token"])
        XCTAssertEqual(repository.token, "new-token")
        XCTAssertTrue(repository.isRegistered)
    }

    func testRegisterPreservesOldStateWhenOldTokenDeleteFails() async {
        let repository = DeviceTokenRepositorySpy(token: "old-token", isRegistered: true)
        repository.unregisterResult = .failure(DeviceTokenTestError.deleteFailed)
        let useCase = makeRegisterUseCase(repository: repository)

        await assertThrows(DeviceTokenTestError.deleteFailed) {
            try await useCase.execute(fcmToken: "new-token")
        }

        XCTAssertEqual(repository.remoteEvents, ["delete:old-token"])
        XCTAssertEqual(repository.token, "old-token")
        XCTAssertTrue(repository.isRegistered)
    }

    func testRegisterKeepsNewTokenUnregisteredWhenPostFails() async {
        let repository = DeviceTokenRepositorySpy(token: "old-token", isRegistered: true)
        repository.registerResult = .failure(DeviceTokenTestError.postFailed)
        let useCase = makeRegisterUseCase(repository: repository)

        await assertThrows(DeviceTokenTestError.postFailed) {
            try await useCase.execute(fcmToken: "new-token")
        }

        XCTAssertEqual(repository.remoteEvents, ["delete:old-token", "post:new-token"])
        XCTAssertEqual(repository.token, "new-token")
        XCTAssertFalse(repository.isRegistered)
    }

    func testUnregisterWithoutTokenSkipsRemoteWork() async throws {
        let repository = DeviceTokenRepositorySpy()
        let lifecycle = makeDeviceTokenLifecycle(repository: repository)

        try await lifecycle.unregisterCurrent()

        XCTAssertTrue(repository.remoteEvents.isEmpty)
    }

    func testUnregisterCallsDeleteEvenWhenRegistrationIsUnconfirmed() async throws {
        let repository = DeviceTokenRepositorySpy(token: "token", isRegistered: false)
        let lifecycle = makeDeviceTokenLifecycle(repository: repository)

        try await lifecycle.unregisterCurrent()

        XCTAssertEqual(repository.remoteEvents, ["delete:token"])
        XCTAssertFalse(repository.isRegistered)
    }

    func testUnregisterFailurePreservesRegistrationState() async {
        let repository = DeviceTokenRepositorySpy(token: "token", isRegistered: true)
        repository.unregisterResult = .failure(DeviceTokenTestError.deleteFailed)
        let lifecycle = makeDeviceTokenLifecycle(repository: repository)

        await assertThrows(DeviceTokenTestError.deleteFailed) {
            try await lifecycle.unregisterCurrent()
        }

        XCTAssertEqual(repository.token, "token")
        XCTAssertTrue(repository.isRegistered)
    }

    private func makeRegisterUseCase(
        repository: DeviceTokenRepositorySpy,
        hasSession: Bool = true
    ) -> DefaultRegisterUserDeviceUseCase {
        let lifecycle = DefaultDeviceTokenLifecycle(
            deviceTokenRepository: repository,
            authRepository: AuthRepositorySessionStub(hasSession: hasSession)
        )

        return DefaultRegisterUserDeviceUseCase(
            lifecycle: lifecycle
        )
    }

    private func makeDeviceTokenLifecycle(
        repository: DeviceTokenRepositorySpy
    ) -> DefaultDeviceTokenLifecycle {
        DefaultDeviceTokenLifecycle(
            deviceTokenRepository: repository,
            authRepository: AuthRepositorySessionStub(hasSession: true)
        )
    }

    private func assertThrows(
        _ expectedError: DeviceTokenTestError,
        operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            XCTFail("Expected error: \(expectedError)")
        } catch let error as DeviceTokenTestError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private enum DeviceTokenTestError: Error, Equatable {
    case postFailed
    case deleteFailed
    case unexpected
}

private final class DeviceTokenRepositorySpy: DeviceTokenRepositoryProtocol {
    var token: String?
    var isRegistered: Bool
    var registerResult: Result<Void, Error> = .success(())
    var unregisterResult: Result<Void, Error> = .success(())
    private(set) var remoteEvents: [String] = []

    init(token: String? = nil, isRegistered: Bool = false) {
        self.token = token
        self.isRegistered = isRegistered
    }

    func registerDevice(fcmToken: String) async throws {
        remoteEvents.append("post:\(fcmToken)")
        try registerResult.get()
    }

    func unregisterDevice(fcmToken: String) async throws {
        remoteEvents.append("delete:\(fcmToken)")
        try unregisterResult.get()
    }

    func loadDeviceToken() -> String? { token }

    func saveDeviceToken(_ token: String) {
        if self.token != token {
            isRegistered = false
        }
        self.token = token
    }

    func isDeviceTokenRegistered() -> Bool { isRegistered }

    func setDeviceTokenRegistered(_ isRegistered: Bool) {
        self.isRegistered = isRegistered
    }

    func clearDeviceToken() {
        token = nil
        isRegistered = false
    }
}

private final class AuthRepositorySessionStub: AuthRepositoryProtocol {
    private var session: AuthSession?

    init(hasSession: Bool) {
        session =
            hasSession
            ? AuthSession(accessToken: "access-token", expiresAt: nil)
            : nil
    }

    func login(with credential: LoginCredential) async throws -> AuthSession {
        throw DeviceTokenTestError.unexpected
    }

    func loginForTest() async throws -> AuthSession {
        throw DeviceTokenTestError.unexpected
    }

    func refreshAccessToken(_ accessToken: String) async throws -> AuthSession {
        throw DeviceTokenTestError.unexpected
    }

    func loadSession() -> AuthSession? { session }
    func saveSession(_ session: AuthSession) { self.session = session }
    func clearSession() { session = nil }
}
