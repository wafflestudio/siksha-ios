//
//  RefreshAccessTokenUseCase.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

protocol RefreshAccessTokenUseCase {
    func execute() async throws -> AuthSession?
}

final class DefaultRefreshAccessTokenUseCase: RefreshAccessTokenUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> AuthSession? {
        guard let currentSession = repository.loadSession() else {
            return nil
        }

        let refreshedSession = try await repository.refreshAccessToken(currentSession.accessToken)
        repository.saveSession(refreshedSession)
        return refreshedSession
    }
}
