//
//  ResolveInitialAuthStateUseCase.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

protocol ResolveInitialAuthStateUseCase {
    func execute() async -> AuthState
}

final class DefaultResolveInitialAuthStateUseCase: ResolveInitialAuthStateUseCase {
    private let authRepository: AuthRepositoryProtocol
    private let refreshAccessTokenUseCase: RefreshAccessTokenUseCase
    private let appleCredentialRepository: AppleCredentialRepositoryProtocol
    private let refreshWindow: TimeInterval
    private let now: () -> Date

    init(
        authRepository: AuthRepositoryProtocol,
        refreshAccessTokenUseCase: RefreshAccessTokenUseCase,
        appleCredentialRepository: AppleCredentialRepositoryProtocol,
        refreshWindow: TimeInterval = 15_552_000,
        now: @escaping () -> Date = { Date() }
    ) {
        self.authRepository = authRepository
        self.refreshAccessTokenUseCase = refreshAccessTokenUseCase
        self.appleCredentialRepository = appleCredentialRepository
        self.refreshWindow = refreshWindow
        self.now = now
    }

    func execute() async -> AuthState {
        guard let session = authRepository.loadSession() else {
            return .requiresLogin
        }

        let currentDate = now()

        guard !session.isExpired(asOf: currentDate) else {
            authRepository.clearSession()
            return .requiresLogin
        }

        if let appleUserIdentifier = session.appleUserIdentifier {
            let credentialStatus = await appleCredentialRepository.credentialStatus(
                for: appleUserIdentifier
            )

            switch credentialStatus {
            case .revoked, .notFound:
                authRepository.clearSession()
                return .requiresLogin
            case .authorized, .unknown:
                break
            }
        }

        guard
            session.needsRefresh(
                asOf: currentDate,
                refreshWindow: refreshWindow
            )
        else {
            return .authenticated(session)
        }

        do {
            guard let refreshedSession = try await refreshAccessTokenUseCase.execute() else {
                return .authenticated(session)
            }
            return .authenticated(refreshedSession)
        } catch {
            authRepository.clearSession()
            return .requiresLogin
        }
    }
}
