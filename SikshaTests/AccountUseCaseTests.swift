//
//  AccountUseCaseTests.swift
//  SikshaTests
//
//  Created by Codex on 7/13/26.
//

import Foundation
import XCTest
@testable import Siksha

final class AccountUseCaseTests: XCTestCase {
    func testAccountCleanupContinuesWhenMessagingTokenDeletionFails() async {
        let messaging = MessagingTokenServiceStub(
            deleteResult: .failure(AccountTestError.firebase)
        )
        let deviceRepository = AccountDeviceTokenRepositorySpy(
            token: "token",
            isRegistered: true
        )
        let authRepository = AccountAuthRepositoryStub(hasSession: true)
        let alarmRepository = MenuAlarmPreferenceRepositorySpy()
        let restaurantStateRepository = PersonalRestaurantStateRepositorySpy()
        let cleaner = DefaultAccountLocalStateCleaner(
            messagingTokenService: messaging,
            deviceTokenRepository: deviceRepository,
            authRepository: authRepository,
            menuAlarmPreferenceRepository: alarmRepository,
            personalRestaurantStateRepository: restaurantStateRepository
        )

        await cleaner.execute()

        XCTAssertEqual(messaging.deleteExecutionCount, 1)
        XCTAssertNil(deviceRepository.token)
        XCTAssertNil(authRepository.loadSession())
        XCTAssertEqual(alarmRepository.values, [false])
        XCTAssertEqual(restaurantStateRepository.clearExecutionCount, 1)
    }

    func testLogoutFailureSkipsCleanup() async {
        let log = AccountOperationLog()
        let repository = AccountDeviceTokenRepositorySpy(
            token: "token",
            isRegistered: true,
            unregisterResult: .failure(AccountTestError.unregister),
            log: log
        )
        let cleaner = AccountLocalStateCleanerSpy(log: log)
        let useCase = DefaultLogoutUseCase(
            deviceTokenLifecycle: makeLifecycle(repository: repository),
            accountLocalStateCleaner: cleaner
        )

        await assertThrows(AccountTestError.unregister) {
            try await useCase.execute()
        }

        XCTAssertEqual(log.values, ["unregister"])
        XCTAssertEqual(cleaner.executionCount, 0)
    }

    func testLogoutSuccessUnregistersBeforeCleanup() async throws {
        let log = AccountOperationLog()
        let repository = AccountDeviceTokenRepositorySpy(
            token: "token",
            isRegistered: true,
            log: log
        )
        let useCase = DefaultLogoutUseCase(
            deviceTokenLifecycle: makeLifecycle(repository: repository),
            accountLocalStateCleaner: AccountLocalStateCleanerSpy(log: log)
        )

        try await useCase.execute()

        XCTAssertEqual(log.values, ["unregister", "cleanup"])
    }

    func testDeleteAccountSuccessUnregistersBeforeDeleteAndCleanup() async throws {
        let dependencies = makeDeleteDependencies()
        let useCase = makeDeleteAccountUseCase(dependencies)

        try await useCase.execute()

        XCTAssertEqual(
            dependencies.log.values,
            ["unregister", "deleteAccount", "cleanup"]
        )
        XCTAssertFalse(dependencies.deviceRepository.isRegistered)
    }

    func testDeleteAccountUnregisterFailureSkipsDeleteAndCleanup() async {
        let dependencies = makeDeleteDependencies(
            unregisterResult: .failure(AccountTestError.unregister)
        )
        let useCase = makeDeleteAccountUseCase(dependencies)

        await assertThrows(AccountTestError.unregister) {
            try await useCase.execute()
        }

        XCTAssertEqual(dependencies.log.values, ["unregister"])
        XCTAssertEqual(dependencies.cleaner.executionCount, 0)
    }

    func testDeleteAccountFailureRestoresDeviceAndPreservesOriginalError() async {
        let dependencies = makeDeleteDependencies(
            deleteResult: .failure(AccountTestError.delete)
        )
        let useCase = makeDeleteAccountUseCase(dependencies)

        await assertDeleteFailure(
            deletionError: .delete,
            restorationError: nil
        ) {
            try await useCase.execute()
        }

        XCTAssertEqual(
            dependencies.log.values,
            ["unregister", "deleteAccount", "register:token"]
        )
        XCTAssertTrue(dependencies.deviceRepository.isRegistered)
        XCTAssertEqual(dependencies.cleaner.executionCount, 0)
    }

    func testDeleteAccountRestoreFailurePreservesBothErrors() async {
        let dependencies = makeDeleteDependencies(
            deleteResult: .failure(AccountTestError.delete),
            registerResult: .failure(AccountTestError.register)
        )
        let useCase = makeDeleteAccountUseCase(dependencies)

        await assertDeleteFailure(
            deletionError: .delete,
            restorationError: .register
        ) {
            try await useCase.execute()
        }

        XCTAssertEqual(
            dependencies.log.values,
            ["unregister", "deleteAccount", "register:token"]
        )
        XCTAssertFalse(dependencies.deviceRepository.isRegistered)
        XCTAssertEqual(dependencies.cleaner.executionCount, 0)
    }

    func testLogoutWaitsForInFlightRegistration() async throws {
        let log = AccountOperationLog()
        let repository = AccountDeviceTokenRepositorySpy(log: log)
        let authRepository = AccountAuthRepositoryStub(hasSession: true)
        let lifecycle = makeLifecycle(
            repository: repository,
            authRepository: authRepository
        )
        let registrationStarted = expectation(description: "registration started")
        let registrationSignal = AsyncSignal()
        repository.registerHandler = {
            registrationStarted.fulfill()
            await registrationSignal.wait()
        }
        let registerUseCase = DefaultRegisterUserDeviceUseCase(lifecycle: lifecycle)
        let logoutUseCase = DefaultLogoutUseCase(
            deviceTokenLifecycle: lifecycle,
            accountLocalStateCleaner: AccountLocalStateCleanerSpy(log: log)
        )

        let registrationTask = Task {
            try await registerUseCase.execute(fcmToken: "token")
        }
        await fulfillment(of: [registrationStarted], timeout: 1)

        let logoutTask = Task {
            try await logoutUseCase.execute()
        }
        await Task.yield()
        XCTAssertEqual(log.values, ["register:token"])

        await registrationSignal.resume()
        try await registrationTask.value
        try await logoutTask.value

        XCTAssertEqual(log.values, ["register:token", "unregister", "cleanup"])
    }

    func testOperationGateSerializesAsyncOperations() async throws {
        let gate = DeviceTokenOperationGate()
        let signal = AsyncSignal()
        let firstStarted = expectation(description: "first operation started")
        let log = AccountOperationLog()

        let firstTask = Task {
            try await gate.withExclusiveAccess {
                log.append("first-start")
                firstStarted.fulfill()
                await signal.wait()
                log.append("first-end")
            }
        }

        await fulfillment(of: [firstStarted], timeout: 1)

        let secondTask = Task {
            try await gate.withExclusiveAccess {
                log.append("second")
            }
        }

        await Task.yield()
        XCTAssertEqual(log.values, ["first-start"])

        await signal.resume()
        try await firstTask.value
        try await secondTask.value

        XCTAssertEqual(log.values, ["first-start", "first-end", "second"])
    }

    func testOperationGateDoesNotRunCancelledWaiter() async throws {
        let gate = DeviceTokenOperationGate()
        let signal = AsyncSignal()
        let firstStarted = expectation(description: "first operation started")
        let secondStarted = expectation(description: "second task started")
        let log = AccountOperationLog()

        let firstTask = Task {
            try await gate.withExclusiveAccess {
                log.append("first-start")
                firstStarted.fulfill()
                await signal.wait()
                log.append("first-end")
            }
        }
        await fulfillment(of: [firstStarted], timeout: 1)

        let secondTask = Task {
            secondStarted.fulfill()
            try await gate.withExclusiveAccess {
                log.append("second")
            }
        }
        await fulfillment(of: [secondStarted], timeout: 1)
        secondTask.cancel()

        await signal.resume()
        try await firstTask.value

        do {
            try await secondTask.value
            XCTFail("Expected cancellation")
        } catch is CancellationError {
            // Expected cancellation while waiting for exclusive access.
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(log.values, ["first-start", "first-end"])
    }

    private func makeDeleteDependencies(
        unregisterResult: Result<Void, Error> = .success(()),
        deleteResult: Result<Void, Error> = .success(()),
        registerResult: Result<Void, Error> = .success(())
    ) -> DeleteDependencies {
        let log = AccountOperationLog()
        let deviceRepository = AccountDeviceTokenRepositorySpy(
            token: "token",
            isRegistered: true,
            registerResult: registerResult,
            unregisterResult: unregisterResult,
            log: log
        )
        let authRepository = AccountAuthRepositoryStub(hasSession: true)

        return DeleteDependencies(
            log: log,
            deviceRepository: deviceRepository,
            lifecycle: makeLifecycle(
                repository: deviceRepository,
                authRepository: authRepository
            ),
            userRepository: AccountUserRepositorySpy(
                deleteResult: deleteResult,
                log: log
            ),
            cleaner: AccountLocalStateCleanerSpy(log: log)
        )
    }

    private func makeDeleteAccountUseCase(
        _ dependencies: DeleteDependencies
    ) -> DefaultDeleteAccountUseCase {
        DefaultDeleteAccountUseCase(
            deviceTokenLifecycle: dependencies.lifecycle,
            userRepository: dependencies.userRepository,
            accountLocalStateCleaner: dependencies.cleaner
        )
    }

    private func makeLifecycle(
        repository: AccountDeviceTokenRepositorySpy,
        authRepository: AccountAuthRepositoryStub = AccountAuthRepositoryStub(hasSession: true)
    ) -> DefaultDeviceTokenLifecycle {
        DefaultDeviceTokenLifecycle(
            deviceTokenRepository: repository,
            authRepository: authRepository
        )
    }

    private func assertThrows(
        _ expectedError: AccountTestError,
        operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            XCTFail("Expected error: \(expectedError)")
        } catch let error as AccountTestError {
            XCTAssertEqual(error, expectedError)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    private func assertDeleteFailure(
        deletionError: AccountTestError,
        restorationError: AccountTestError?,
        operation: () async throws -> Void
    ) async {
        do {
            try await operation()
            XCTFail("Expected DeleteAccountFailure")
        } catch let failure as DeleteAccountFailure {
            XCTAssertEqual(
                failure.accountDeletionError as? AccountTestError,
                deletionError
            )
            XCTAssertEqual(
                failure.deviceRestorationError as? AccountTestError,
                restorationError
            )
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}

private struct DeleteDependencies {
    let log: AccountOperationLog
    let deviceRepository: AccountDeviceTokenRepositorySpy
    let lifecycle: DefaultDeviceTokenLifecycle
    let userRepository: AccountUserRepositorySpy
    let cleaner: AccountLocalStateCleanerSpy
}

private enum AccountTestError: Error, Equatable {
    case firebase
    case unregister
    case delete
    case register
    case unexpected
}

private final class AccountOperationLog: @unchecked Sendable {
    private let lock = NSLock()
    private var storedValues: [String] = []

    var values: [String] {
        lock.lock()
        defer { lock.unlock() }
        return storedValues
    }

    func append(_ value: String) {
        lock.lock()
        storedValues.append(value)
        lock.unlock()
    }
}

private actor AsyncSignal {
    private var continuation: CheckedContinuation<Void, Never>?
    private var isSignaled = false

    func wait() async {
        guard !isSignaled else { return }
        await withCheckedContinuation { continuation = $0 }
    }

    func resume() {
        if let continuation {
            self.continuation = nil
            continuation.resume()
        } else {
            isSignaled = true
        }
    }
}

private final class MessagingTokenServiceStub: PushMessagingTokenServiceProtocol {
    private let deleteResult: Result<Void, Error>
    private(set) var deleteExecutionCount = 0

    init(deleteResult: Result<Void, Error>) {
        self.deleteResult = deleteResult
    }

    func setAPNSToken(_ token: Data) {}
    func fetchToken() async throws -> String { "token" }

    func deleteToken() async throws {
        deleteExecutionCount += 1
        try deleteResult.get()
    }
}

private final class AccountDeviceTokenRepositorySpy: DeviceTokenRepositoryProtocol {
    var token: String?
    var isRegistered: Bool
    var registerHandler: (() async -> Void)?

    private let registerResult: Result<Void, Error>
    private let unregisterResult: Result<Void, Error>
    private let log: AccountOperationLog?

    init(
        token: String? = nil,
        isRegistered: Bool = false,
        registerResult: Result<Void, Error> = .success(()),
        unregisterResult: Result<Void, Error> = .success(()),
        log: AccountOperationLog? = nil
    ) {
        self.token = token
        self.isRegistered = isRegistered
        self.registerResult = registerResult
        self.unregisterResult = unregisterResult
        self.log = log
    }

    func registerDevice(fcmToken: String) async throws {
        log?.append("register:\(fcmToken)")
        await registerHandler?()
        try registerResult.get()
    }

    func unregisterDevice(fcmToken: String) async throws {
        log?.append("unregister")
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
    func setDeviceTokenRegistered(_ isRegistered: Bool) { self.isRegistered = isRegistered }

    func clearDeviceToken() {
        token = nil
        isRegistered = false
    }
}

private final class AccountAuthRepositoryStub: AuthRepositoryProtocol {
    private var session: AuthSession?

    init(hasSession: Bool) {
        session = hasSession ? AuthSession(accessToken: "access-token", expiresAt: nil) : nil
    }

    func login(with credential: LoginCredential) async throws -> AuthSession {
        throw AccountTestError.unexpected
    }

    func loginForTest() async throws -> AuthSession { throw AccountTestError.unexpected }

    func refreshAccessToken(_ accessToken: String) async throws -> AuthSession {
        throw AccountTestError.unexpected
    }

    func loadSession() -> AuthSession? { session }
    func saveSession(_ session: AuthSession) { self.session = session }
    func clearSession() { session = nil }
}

private final class MenuAlarmPreferenceRepositorySpy: MenuAlarmPreferenceRepositoryProtocol {
    private(set) var values: [Bool] = []
    func setAlarmEnabled(_ enabled: Bool) { values.append(enabled) }
}

private final class PersonalRestaurantStateRepositorySpy: PersonalRestaurantStateRepositoryProtocol {
    private(set) var clearExecutionCount = 0

    func clearPersonalRestaurants() {
        clearExecutionCount += 1
    }
}

private final class AccountUserRepositorySpy: UserRepositoryProtocol {
    private let deleteResult: Result<Void, Error>
    private let log: AccountOperationLog

    init(deleteResult: Result<Void, Error>, log: AccountOperationLog) {
        self.deleteResult = deleteResult
        self.log = log
    }

    func fetchCurrentUser() async throws -> User { throw AccountTestError.unexpected }

    func updateProfile(
        nickname: String?,
        image: Data?,
        changeToDefaultImage: Bool
    ) async throws -> User {
        throw AccountTestError.unexpected
    }

    func submitVOC(comment: String, platform: String) async throws {
        throw AccountTestError.unexpected
    }

    func deleteAccount() async throws {
        log.append("deleteAccount")
        try deleteResult.get()
    }
}

private final class AccountLocalStateCleanerSpy: AccountLocalStateCleaner {
    private let log: AccountOperationLog
    private(set) var executionCount = 0

    init(log: AccountOperationLog) {
        self.log = log
    }

    func execute() async {
        executionCount += 1
        log.append("cleanup")
    }
}
