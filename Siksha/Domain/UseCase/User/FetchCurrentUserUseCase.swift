//
//  FetchCurrentUserUseCase.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

protocol FetchCurrentUserUseCase {
    func execute() async throws -> User
}

final class DefaultFetchCurrentUserUseCase: FetchCurrentUserUseCase {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> User {
        try await repository.fetchCurrentUser()
    }
}
