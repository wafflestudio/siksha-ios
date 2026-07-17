//
//  AuthUseCaseTests.swift
//  SikshaTests
//
//  Created by Codex on 7/16/26.
//

import XCTest

@testable import Siksha

final class AuthUseCaseTests: XCTestCase {
    func testProviderLoginSavesReturnedSessionAfterLogin() async throws {
        let session = makeSession(accessToken: "new-access-token")
        let repository = AuthUseCaseRepositorySpy()
        repository.loginResult = .success(session)
        let useCase = DefaultLoginUseCase(repository: repository)

        let returnedSession = try await useCase.login(
            with: LoginCredential(provider: .kakao, token: "provider-token")
        )

        XCTAssertEqual(returnedSession.accessToken, "new-access-token")
        XCTAssertEqual(
            repository.events,
            ["login:kakao:provider-token", "save:new-access-token"]
        )
        XCTAssertEqual(repository.savedSessions.count, 1)
    }

    func testProviderLoginFailureDoesNotSaveOrClearSession() async {
        let repository = AuthUseCaseRepositorySpy()
        repository.loginResult = .failure(AuthUseCaseTestError.loginFailed)
        let useCase = DefaultLoginUseCase(repository: repository)

        do {
            _ = try await useCase.login(
                with: LoginCredential(provider: .google, token: "provider-token")
            )
            XCTFail("Expected login error")
        } catch let error as AuthUseCaseTestError {
            XCTAssertEqual(error, .loginFailed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(repository.events, ["login:google:provider-token"])
        XCTAssertTrue(repository.savedSessions.isEmpty)
        XCTAssertEqual(repository.clearCount, 0)
    }

    func testLoginForTestSavesReturnedSessionAfterLogin() async throws {
        let repository = AuthUseCaseRepositorySpy()
        repository.testLoginResult = .success(
            makeSession(accessToken: "test-access-token")
        )
        let useCase = DefaultLoginUseCase(repository: repository)

        let returnedSession = try await useCase.loginForTest()

        XCTAssertEqual(returnedSession.accessToken, "test-access-token")
        XCTAssertEqual(
            repository.events,
            ["testLogin", "save:test-access-token"]
        )
        XCTAssertEqual(repository.savedSessions.count, 1)
    }

    func testLoginForTestFailureDoesNotSaveOrClearSession() async {
        let repository = AuthUseCaseRepositorySpy()
        repository.testLoginResult = .failure(AuthUseCaseTestError.loginFailed)
        let useCase = DefaultLoginUseCase(repository: repository)

        do {
            _ = try await useCase.loginForTest()
            XCTFail("Expected login error")
        } catch let error as AuthUseCaseTestError {
            XCTAssertEqual(error, .loginFailed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(repository.events, ["testLogin"])
        XCTAssertTrue(repository.savedSessions.isEmpty)
        XCTAssertEqual(repository.clearCount, 0)
    }

    func testRefreshWithoutStoredSessionReturnsNilWithoutRemoteWork() async throws {
        let repository = AuthUseCaseRepositorySpy()
        repository.sessionToLoad = nil
        let useCase = DefaultRefreshAccessTokenUseCase(repository: repository)

        let session = try await useCase.execute()

        XCTAssertNil(session)
        XCTAssertEqual(repository.events, ["load"])
        XCTAssertTrue(repository.savedSessions.isEmpty)
    }

    func testRefreshSavesReturnedSessionAfterRefresh() async throws {
        let repository = AuthUseCaseRepositorySpy()
        repository.sessionToLoad = makeSession(accessToken: "old-access-token")
        repository.refreshResult = .success(
            makeSession(accessToken: "new-access-token")
        )
        let useCase = DefaultRefreshAccessTokenUseCase(repository: repository)

        let session = try await useCase.execute()

        XCTAssertEqual(session?.accessToken, "new-access-token")
        XCTAssertEqual(
            repository.events,
            ["load", "refresh:old-access-token", "save:new-access-token"]
        )
        XCTAssertEqual(repository.savedSessions.count, 1)
    }

    func testRefreshFailureDoesNotSaveOrClearSession() async {
        let repository = AuthUseCaseRepositorySpy()
        repository.sessionToLoad = makeSession(accessToken: "old-access-token")
        repository.refreshResult = .failure(AuthUseCaseTestError.refreshFailed)
        let useCase = DefaultRefreshAccessTokenUseCase(repository: repository)

        do {
            _ = try await useCase.execute()
            XCTFail("Expected refresh error")
        } catch let error as AuthUseCaseTestError {
            XCTAssertEqual(error, .refreshFailed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(repository.events, ["load", "refresh:old-access-token"])
        XCTAssertTrue(repository.savedSessions.isEmpty)
        XCTAssertEqual(repository.clearCount, 0)
    }

    private func makeSession(accessToken: String) -> AuthSession {
        AuthSession(accessToken: accessToken, expiresAt: nil)
    }
}

private enum AuthUseCaseTestError: Error, Equatable {
    case loginFailed
    case refreshFailed
    case unconfigured
}

private final class AuthUseCaseRepositorySpy: AuthRepositoryProtocol {
    var loginResult: Result<AuthSession, Error> = .failure(
        AuthUseCaseTestError.unconfigured
    )
    var testLoginResult: Result<AuthSession, Error> = .failure(
        AuthUseCaseTestError.unconfigured
    )
    var refreshResult: Result<AuthSession, Error> = .failure(
        AuthUseCaseTestError.unconfigured
    )
    var sessionToLoad: AuthSession?
    private(set) var savedSessions: [AuthSession] = []
    private(set) var clearCount = 0
    private(set) var events: [String] = []

    func login(with credential: LoginCredential) async throws -> AuthSession {
        events.append("login:\(credential.provider.rawValue):\(credential.token)")
        return try loginResult.get()
    }

    func loginForTest() async throws -> AuthSession {
        events.append("testLogin")
        return try testLoginResult.get()
    }

    func refreshAccessToken(_ accessToken: String) async throws -> AuthSession {
        events.append("refresh:\(accessToken)")
        return try refreshResult.get()
    }

    func loadSession() -> AuthSession? {
        events.append("load")
        return sessionToLoad
    }

    func saveSession(_ session: AuthSession) {
        events.append("save:\(session.accessToken)")
        savedSessions.append(session)
        sessionToLoad = session
    }

    func clearSession() {
        events.append("clear")
        clearCount += 1
        sessionToLoad = nil
    }
}
