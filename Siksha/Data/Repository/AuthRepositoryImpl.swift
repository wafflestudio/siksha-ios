//
//  AuthRepositoryImpl.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

final class AuthRepositoryImpl: AuthRepositoryProtocol {
    private let remote: AuthRemoteDataSource
    private let local: AuthSessionLocalDataSource
    private let tokenDecoder: JWTTokenDecoder

    init(
        remote: AuthRemoteDataSource,
        local: AuthSessionLocalDataSource,
        tokenDecoder: JWTTokenDecoder = JWTTokenDecoder()
    ) {
        self.remote = remote
        self.local = local
        self.tokenDecoder = tokenDecoder
    }

    func login(with credential: LoginCredential) async throws -> AuthSession {
        let response = try await remote.login(
            provider: credential.provider,
            token: credential.token
        )

        return makeSession(
            accessToken: response.accessToken,
            appleUserIdentifier: credential.appleUserIdentifier
        )
    }

    func loginForTest() async throws -> AuthSession {
        let response = try await remote.loginForTest()
        return makeSession(accessToken: response.accessToken)
    }

    func refreshAccessToken(_ accessToken: String) async throws -> AuthSession {
        let response = try await remote.refreshAccessToken(accessToken)
        return makeSession(
            accessToken: response.accessToken,
            appleUserIdentifier: local.loadSession()?.appleUserIdentifier
        )
    }

    func loadSession() -> AuthSession? {
        local.loadSession()
    }

    func saveSession(_ session: AuthSession) {
        local.saveSession(session)
    }

    func clearSession() {
        local.clearSession()
    }

    private func makeSession(
        accessToken: String,
        appleUserIdentifier: String? = nil
    ) -> AuthSession {
        AuthSession(
            accessToken: accessToken,
            expiresAt: tokenDecoder.expirationDate(from: accessToken),
            appleUserIdentifier: appleUserIdentifier
        )
    }
}
