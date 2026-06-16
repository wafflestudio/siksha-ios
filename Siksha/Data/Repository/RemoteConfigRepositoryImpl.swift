//
//  RemoteConfigRepositoryImpl.swift
//  Siksha
//
//  Created by Codex on 6/4/26.
//

import Foundation

final class RemoteConfigRepositoryImpl: RemoteConfigRepositoryProtocol {
    private let dataSource: RemoteConfigDataSource

    init(dataSource: RemoteConfigDataSource = FirebaseRemoteConfigDataSource()) {
        self.dataSource = dataSource
    }

    func fetchRemoteConfig() async throws -> RemoteConfigModel {
        try await dataSource.fetchRemoteConfig().toDomain()
    }

    func observeRemoteConfigUpdates() -> AsyncStream<RemoteConfigModel> {
        AsyncStream { continuation in
            let task = Task {
                for await config in dataSource.observeRemoteConfigUpdates() {
                    continuation.yield(config.toDomain())
                }
                continuation.finish()
            }

            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }
}
