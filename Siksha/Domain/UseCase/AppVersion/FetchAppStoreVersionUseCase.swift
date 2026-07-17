//
//  FetchAppStoreVersionUseCase.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

protocol FetchAppStoreVersionUseCase {
    func execute() async throws -> AppVersion
}

final class DefaultFetchAppStoreVersionUseCase: FetchAppStoreVersionUseCase {
    private let repository: AppVersionRepositoryProtocol

    init(repository: AppVersionRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> AppVersion {
        try await repository.fetchLatestAppStoreVersion()
    }
}
