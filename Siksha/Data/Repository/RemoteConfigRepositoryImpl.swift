//
//  RemoteConfigRepositoryImpl.swift
//  Siksha
//
//  Created by Codex on 6/4/26.
//

import Foundation

final class RemoteConfigRepositoryImpl: RemoteConfigRepositoryProtocol {
    private let dataSource: RemoteConfigDataSource

    init(dataSource: RemoteConfigDataSource) {
        self.dataSource = dataSource
    }

    func fetchRemoteConfig() async throws -> RemoteConfigModel {
        try await dataSource.fetchRemoteConfig().toDomain()
    }

    func observeRemoteConfigUpdates() -> AsyncStream<RemoteConfigModel> {
        let dataSource = dataSource

        return AsyncStream { continuation in
            let task = Task {
                let updates = await dataSource.observeRemoteConfigUpdates()

                for await config in updates {
                    guard !Task.isCancelled else {
                        break
                    }
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
