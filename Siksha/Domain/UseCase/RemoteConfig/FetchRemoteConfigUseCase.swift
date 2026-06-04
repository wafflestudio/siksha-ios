//
//  FetchRemoteConfigUseCase.swift
//  Siksha
//
//  Created by Codex on 6/4/26.
//

import Foundation

protocol FetchRemoteConfigUseCase {
    func execute() async throws -> RemoteConfigModel
}

final class DefaultFetchRemoteConfigUseCase: FetchRemoteConfigUseCase {
    private let repository: RemoteConfigRepositoryProtocol

    init(repository: RemoteConfigRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> RemoteConfigModel {
        try await repository.fetchRemoteConfig()
    }
}
