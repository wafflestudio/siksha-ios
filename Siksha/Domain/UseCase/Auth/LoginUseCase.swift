//
//  LoginUseCase.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

protocol LoginUseCase {
    func login(with credential: LoginCredential) async throws -> AuthSession
    func loginForTest() async throws -> AuthSession
}

final class DefaultLoginUseCase: LoginUseCase {
    private let repository: AuthRepositoryProtocol

    init(repository: AuthRepositoryProtocol) {
        self.repository = repository
    }

    func login(with credential: LoginCredential) async throws -> AuthSession {
        let session = try await repository.login(with: credential)
        repository.saveSession(session)
        return session
    }

    func loginForTest() async throws -> AuthSession {
        let session = try await repository.loginForTest()
        repository.saveSession(session)
        return session
    }
}
