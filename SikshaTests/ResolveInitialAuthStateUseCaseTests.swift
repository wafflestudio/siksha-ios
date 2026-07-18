//
//  ResolveInitialAuthStateUseCaseTests.swift
//  SikshaTests
//
//  Created by Codex on 7/16/26.
//

import Foundation
import XCTest

@testable import Siksha

final class ResolveInitialAuthStateUseCaseTests: XCTestCase {
    private let now = Date(timeIntervalSince1970: 2_000_000_000)
    private let refreshWindow: TimeInterval = 100

    func testNoSessionRequiresLoginWithoutClearingOrExternalWork() async {
        let context = makeContext(session: nil)

        let state = await context.useCase.execute()

        assertRequiresLogin(state)
        XCTAssertEqual(context.authRepository.loadCount, 1)
        XCTAssertEqual(context.authRepository.clearCount, 0)
        XCTAssertEqual(context.refreshUseCase.executionCount, 0)
        XCTAssertTrue(context.appleRepository.requestedIdentifiers.isEmpty)
    }

    func testSessionExpiringNowIsClearedBeforeAppleOrRefreshWork() async {
        let context = makeContext(
            session: makeSession(
                expiresAt: now,
                appleUserIdentifier: "apple-user"
            )
        )

        let state = await context.useCase.execute()

        assertRequiresLogin(state)
        XCTAssertEqual(context.authRepository.clearCount, 1)
        XCTAssertEqual(context.refreshUseCase.executionCount, 0)
        XCTAssertTrue(context.appleRepository.requestedIdentifiers.isEmpty)
    }

    func testSessionWithoutExpirationIsAuthenticatedWithoutRefresh() async {
        let session = makeSession(expiresAt: nil)
        let context = makeContext(session: session)

        let state = await context.useCase.execute()

        assertAuthenticated(state, accessToken: session.accessToken)
        XCTAssertEqual(context.authRepository.clearCount, 0)
        XCTAssertEqual(context.refreshUseCase.executionCount, 0)
        XCTAssertTrue(context.appleRepository.requestedIdentifiers.isEmpty)
    }

    func testSessionOutsideRefreshWindowIsAuthenticatedWithoutRefresh() async {
        let session = makeSession(
            expiresAt: now.addingTimeInterval(refreshWindow + 1)
        )
        let context = makeContext(session: session)

        let state = await context.useCase.execute()

        assertAuthenticated(state, accessToken: session.accessToken)
        XCTAssertEqual(context.refreshUseCase.executionCount, 0)
        XCTAssertEqual(context.authRepository.clearCount, 0)
    }

    func testSessionAtRefreshWindowBoundaryIsNotRefreshed() async {
        let session = makeSession(
            expiresAt: now.addingTimeInterval(refreshWindow)
        )
        let context = makeContext(session: session)

        let state = await context.useCase.execute()

        assertAuthenticated(state, accessToken: session.accessToken)
        XCTAssertEqual(context.refreshUseCase.executionCount, 0)
        XCTAssertEqual(context.authRepository.clearCount, 0)
    }

    func testRevokedAppleCredentialClearsSessionAndSkipsRefresh() async {
        let context = makeContext(
            session: makeSession(
                expiresAt: now.addingTimeInterval(50),
                appleUserIdentifier: "apple-user"
            ),
            appleStatus: .revoked
        )

        let state = await context.useCase.execute()

        assertRequiresLogin(state)
        XCTAssertEqual(context.appleRepository.requestedIdentifiers, ["apple-user"])
        XCTAssertEqual(context.authRepository.clearCount, 1)
        XCTAssertEqual(context.refreshUseCase.executionCount, 0)
    }

    func testNotFoundAppleCredentialClearsSessionAndSkipsRefresh() async {
        let context = makeContext(
            session: makeSession(
                expiresAt: now.addingTimeInterval(50),
                appleUserIdentifier: "apple-user"
            ),
            appleStatus: .notFound
        )

        let state = await context.useCase.execute()

        assertRequiresLogin(state)
        XCTAssertEqual(context.appleRepository.requestedIdentifiers, ["apple-user"])
        XCTAssertEqual(context.authRepository.clearCount, 1)
        XCTAssertEqual(context.refreshUseCase.executionCount, 0)
    }

    func testAuthorizedAppleCredentialKeepsSession() async {
        let session = makeSession(
            expiresAt: nil,
            appleUserIdentifier: "apple-user"
        )
        let context = makeContext(session: session, appleStatus: .authorized)

        let state = await context.useCase.execute()

        assertAuthenticated(state, accessToken: session.accessToken)
        XCTAssertEqual(context.appleRepository.requestedIdentifiers, ["apple-user"])
        XCTAssertEqual(context.authRepository.clearCount, 0)
        XCTAssertEqual(context.refreshUseCase.executionCount, 0)
    }

    func testUnknownAppleCredentialKeepsSession() async {
        let session = makeSession(
            expiresAt: nil,
            appleUserIdentifier: "apple-user"
        )
        let context = makeContext(session: session, appleStatus: .unknown)

        let state = await context.useCase.execute()

        assertAuthenticated(state, accessToken: session.accessToken)
        XCTAssertEqual(context.appleRepository.requestedIdentifiers, ["apple-user"])
        XCTAssertEqual(context.authRepository.clearCount, 0)
        XCTAssertEqual(context.refreshUseCase.executionCount, 0)
    }

    func testRefreshSuccessAuthenticatesRefreshedSession() async {
        let refreshedSession = AuthSession(
            accessToken: "refreshed-access-token",
            expiresAt: now.addingTimeInterval(1_000)
        )
        let context = makeContext(
            session: makeSession(expiresAt: now.addingTimeInterval(50)),
            refreshResult: .success(refreshedSession)
        )

        let state = await context.useCase.execute()

        assertAuthenticated(state, accessToken: "refreshed-access-token")
        XCTAssertEqual(context.refreshUseCase.executionCount, 1)
        XCTAssertEqual(context.authRepository.clearCount, 0)
    }

    func testNilRefreshResultKeepsOriginalSession() async {
        let originalSession = makeSession(
            accessToken: "original-access-token",
            expiresAt: now.addingTimeInterval(50)
        )
        let context = makeContext(
            session: originalSession,
            refreshResult: .success(nil)
        )

        let state = await context.useCase.execute()

        assertAuthenticated(state, accessToken: "original-access-token")
        XCTAssertEqual(context.refreshUseCase.executionCount, 1)
        XCTAssertEqual(context.authRepository.clearCount, 0)
    }

    func testRefreshFailureClearsSessionAndRequiresLogin() async {
        let context = makeContext(
            session: makeSession(expiresAt: now.addingTimeInterval(50)),
            refreshResult: .failure(InitialAuthTestError.refreshFailed)
        )

        let state = await context.useCase.execute()

        assertRequiresLogin(state)
        XCTAssertEqual(context.refreshUseCase.executionCount, 1)
        XCTAssertEqual(context.authRepository.clearCount, 1)
    }

    private func makeContext(
        session: AuthSession?,
        appleStatus: AppleCredentialStatus = .authorized,
        refreshResult: Result<AuthSession?, Error> = .success(nil)
    ) -> InitialAuthTestContext {
        let authRepository = InitialAuthRepositorySpy(session: session)
        let refreshUseCase = InitialRefreshAccessTokenUseCaseStub(result: refreshResult)
        let appleRepository = InitialAppleCredentialRepositorySpy(status: appleStatus)
        let currentDate = now
        let useCase = DefaultResolveInitialAuthStateUseCase(
            authRepository: authRepository,
            refreshAccessTokenUseCase: refreshUseCase,
            appleCredentialRepository: appleRepository,
            refreshWindow: refreshWindow,
            now: { currentDate }
        )

        return InitialAuthTestContext(
            useCase: useCase,
            authRepository: authRepository,
            refreshUseCase: refreshUseCase,
            appleRepository: appleRepository
        )
    }

    private func makeSession(
        accessToken: String = "access-token",
        expiresAt: Date?,
        appleUserIdentifier: String? = nil
    ) -> AuthSession {
        AuthSession(
            accessToken: accessToken,
            expiresAt: expiresAt,
            appleUserIdentifier: appleUserIdentifier
        )
    }

    private func assertRequiresLogin(
        _ state: AuthState,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .requiresLogin = state else {
            return XCTFail("Expected requiresLogin", file: file, line: line)
        }
    }

    private func assertAuthenticated(
        _ state: AuthState,
        accessToken: String,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case let .authenticated(session) = state else {
            return XCTFail("Expected authenticated", file: file, line: line)
        }

        XCTAssertEqual(session.accessToken, accessToken, file: file, line: line)
    }
}

private struct InitialAuthTestContext {
    let useCase: DefaultResolveInitialAuthStateUseCase
    let authRepository: InitialAuthRepositorySpy
    let refreshUseCase: InitialRefreshAccessTokenUseCaseStub
    let appleRepository: InitialAppleCredentialRepositorySpy
}

private enum InitialAuthTestError: Error {
    case refreshFailed
    case unexpected
}

private final class InitialAuthRepositorySpy: AuthRepositoryProtocol {
    private var session: AuthSession?
    private(set) var loadCount = 0
    private(set) var clearCount = 0

    init(session: AuthSession?) {
        self.session = session
    }

    func login(with credential: LoginCredential) async throws -> AuthSession {
        throw InitialAuthTestError.unexpected
    }

    func loginForTest() async throws -> AuthSession {
        throw InitialAuthTestError.unexpected
    }

    func refreshAccessToken(_ accessToken: String) async throws -> AuthSession {
        throw InitialAuthTestError.unexpected
    }

    func loadSession() -> AuthSession? {
        loadCount += 1
        return session
    }

    func saveSession(_ session: AuthSession) {
        self.session = session
    }

    func clearSession() {
        clearCount += 1
        session = nil
    }
}

private final class InitialRefreshAccessTokenUseCaseStub: RefreshAccessTokenUseCase {
    private let result: Result<AuthSession?, Error>
    private(set) var executionCount = 0

    init(result: Result<AuthSession?, Error>) {
        self.result = result
    }

    func execute() async throws -> AuthSession? {
        executionCount += 1
        return try result.get()
    }
}

private final class InitialAppleCredentialRepositorySpy: AppleCredentialRepositoryProtocol {
    private let status: AppleCredentialStatus
    private(set) var requestedIdentifiers: [String] = []

    init(status: AppleCredentialStatus) {
        self.status = status
    }

    func credentialStatus(for userIdentifier: String) async -> AppleCredentialStatus {
        requestedIdentifiers.append(userIdentifier)
        return status
    }
}
