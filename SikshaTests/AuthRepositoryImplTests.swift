//
//  AuthRepositoryImplTests.swift
//  SikshaTests
//
//  Created by Codex on 7/16/26.
//

import Foundation
import XCTest
@testable import Siksha

final class AuthRepositoryImplTests: XCTestCase {
    func testProviderLoginForwardsCredentialAndMapsSession() async throws {
        let remote = AuthRemoteDataSourceSpy()
        let local = AuthSessionLocalDataSourceSpy()
        let expiration: TimeInterval = 2_000_000_000
        let accessToken = try makeJWT(expiration: expiration)
        remote.loginResult = .success(
            AuthTokenResponseDTO(accessToken: accessToken)
        )
        let repository = makeRepository(remote: remote, local: local)

        let session = try await repository.login(
            with: LoginCredential(
                provider: .apple,
                token: "identity-token",
                appleUserIdentifier: "apple-user"
            )
        )

        XCTAssertEqual(remote.events, ["login:apple:identity-token"])
        XCTAssertEqual(session.accessToken, accessToken)
        XCTAssertEqual(session.expiresAt?.timeIntervalSince1970, expiration)
        XCTAssertEqual(session.appleUserIdentifier, "apple-user")
        XCTAssertTrue(local.events.isEmpty)
    }

    func testLoginForTestUsesTestEndpointAndReturnsNonAppleSession() async throws {
        let remote = AuthRemoteDataSourceSpy()
        let local = AuthSessionLocalDataSourceSpy()
        remote.testLoginResult = .success(
            AuthTokenResponseDTO(accessToken: "test-access-token")
        )
        let repository = makeRepository(remote: remote, local: local)

        let session = try await repository.loginForTest()

        XCTAssertEqual(remote.events, ["testLogin"])
        XCTAssertEqual(session.accessToken, "test-access-token")
        XCTAssertNil(session.expiresAt)
        XCTAssertNil(session.appleUserIdentifier)
        XCTAssertTrue(local.events.isEmpty)
    }

    func testRefreshForwardsAccessTokenAndPreservesStoredAppleIdentifier() async throws {
        let expiration: TimeInterval = 2_100_000_000
        let remote = AuthRemoteDataSourceSpy()
        let refreshedAccessToken = try makeJWT(expiration: expiration)
        remote.refreshResult = .success(
            AuthTokenResponseDTO(accessToken: refreshedAccessToken)
        )
        let local = AuthSessionLocalDataSourceSpy(
            storedSession: AuthSession(
                accessToken: "old-access-token",
                expiresAt: nil,
                appleUserIdentifier: "apple-user"
            )
        )
        let repository = makeRepository(remote: remote, local: local)

        let session = try await repository.refreshAccessToken("old-access-token")

        XCTAssertEqual(remote.events, ["refresh:old-access-token"])
        XCTAssertEqual(local.events, ["load"])
        XCTAssertEqual(session.accessToken, refreshedAccessToken)
        XCTAssertEqual(session.expiresAt?.timeIntervalSince1970, expiration)
        XCTAssertEqual(session.appleUserIdentifier, "apple-user")
    }

    func testMalformedJWTHasNoExpiration() async throws {
        let remote = AuthRemoteDataSourceSpy()
        remote.testLoginResult = .success(
            AuthTokenResponseDTO(accessToken: "malformed-token")
        )
        let repository = makeRepository(
            remote: remote,
            local: AuthSessionLocalDataSourceSpy()
        )

        let session = try await repository.loginForTest()

        XCTAssertNil(session.expiresAt)
    }

    func testJWTWithoutExpirationHasNoExpiration() async throws {
        let remote = AuthRemoteDataSourceSpy()
        remote.testLoginResult = .success(
            AuthTokenResponseDTO(accessToken: try makeJWT(expiration: nil))
        )
        let repository = makeRepository(
            remote: remote,
            local: AuthSessionLocalDataSourceSpy()
        )

        let session = try await repository.loginForTest()

        XCTAssertNil(session.expiresAt)
    }

    func testProviderLoginErrorIsPropagatedWithoutLocalMutation() async {
        let remote = AuthRemoteDataSourceSpy()
        remote.loginResult = .failure(AuthRepositoryTestError.remoteFailed)
        let local = AuthSessionLocalDataSourceSpy()
        let repository = makeRepository(remote: remote, local: local)

        do {
            _ = try await repository.login(
                with: LoginCredential(provider: .google, token: "id-token")
            )
            XCTFail("Expected remote error")
        } catch let error as AuthRepositoryTestError {
            XCTAssertEqual(error, .remoteFailed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(remote.events, ["login:google:id-token"])
        XCTAssertTrue(local.events.isEmpty)
    }

    func testRefreshErrorIsPropagatedWithoutLocalMutation() async {
        let remote = AuthRemoteDataSourceSpy()
        remote.refreshResult = .failure(AuthRepositoryTestError.remoteFailed)
        let local = AuthSessionLocalDataSourceSpy()
        let repository = makeRepository(remote: remote, local: local)

        do {
            _ = try await repository.refreshAccessToken("old-access-token")
            XCTFail("Expected remote error")
        } catch let error as AuthRepositoryTestError {
            XCTAssertEqual(error, .remoteFailed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }

        XCTAssertEqual(remote.events, ["refresh:old-access-token"])
        XCTAssertTrue(local.events.isEmpty)
    }

    func testSessionPersistenceMethodsDelegateToLocalDataSource() throws {
        let remote = AuthRemoteDataSourceSpy()
        let local = AuthSessionLocalDataSourceSpy(
            storedSession: AuthSession(
                accessToken: "stored-token",
                expiresAt: nil
            )
        )
        let repository = makeRepository(remote: remote, local: local)

        let loadedSession = try XCTUnwrap(repository.loadSession())
        repository.saveSession(
            AuthSession(accessToken: "new-token", expiresAt: nil)
        )
        repository.clearSession()

        XCTAssertEqual(loadedSession.accessToken, "stored-token")
        XCTAssertEqual(local.events, ["load", "save:new-token", "clear"])
        XCTAssertNil(local.storedSession)
        XCTAssertTrue(remote.events.isEmpty)
    }

    private func makeRepository(
        remote: AuthRemoteDataSource,
        local: AuthSessionLocalDataSource
    ) -> AuthRepositoryImpl {
        AuthRepositoryImpl(remote: remote, local: local)
    }

    private func makeJWT(expiration: TimeInterval?) throws -> String {
        var payload: [String: Any] = [:]
        if let expiration {
            payload["exp"] = expiration
        }

        let payloadData = try JSONSerialization.data(withJSONObject: payload)
        let payloadSegment = payloadData
            .base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")

        return "header.\(payloadSegment).signature"
    }
}

private enum AuthRepositoryTestError: Error, Equatable {
    case remoteFailed
    case unconfigured
}

private final class AuthRemoteDataSourceSpy: AuthRemoteDataSource {
    var loginResult: Result<AuthTokenResponseDTO, Error> = .failure(
        AuthRepositoryTestError.unconfigured
    )
    var testLoginResult: Result<AuthTokenResponseDTO, Error> = .failure(
        AuthRepositoryTestError.unconfigured
    )
    var refreshResult: Result<AuthTokenResponseDTO, Error> = .failure(
        AuthRepositoryTestError.unconfigured
    )
    private(set) var events: [String] = []

    func login(provider: LoginProvider, token: String) async throws -> AuthTokenResponseDTO {
        events.append("login:\(provider.rawValue):\(token)")
        return try loginResult.get()
    }

    func loginForTest() async throws -> AuthTokenResponseDTO {
        events.append("testLogin")
        return try testLoginResult.get()
    }

    func refreshAccessToken(_ accessToken: String) async throws -> AuthTokenResponseDTO {
        events.append("refresh:\(accessToken)")
        return try refreshResult.get()
    }
}

private final class AuthSessionLocalDataSourceSpy: AuthSessionLocalDataSource {
    var storedSession: AuthSession?
    private(set) var events: [String] = []

    init(storedSession: AuthSession? = nil) {
        self.storedSession = storedSession
    }

    func loadSession() -> AuthSession? {
        events.append("load")
        return storedSession
    }

    func saveSession(_ session: AuthSession) {
        events.append("save:\(session.accessToken)")
        storedSession = session
    }

    func clearSession() {
        events.append("clear")
        storedSession = nil
    }
}
