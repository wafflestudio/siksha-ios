//
//  RemoteConfigDataSource.swift
//  Siksha
//
//  Created by Codex on 6/4/26.
//

import Foundation
import FirebaseRemoteConfig

protocol RemoteConfigDataSource {
    func fetchRemoteConfig() async throws -> RemoteConfigDTO
    func observeRemoteConfigUpdates() -> AsyncStream<RemoteConfigDTO>
}

final class FirebaseRemoteConfigDataSource: RemoteConfigDataSource {
    private let remoteConfig: RemoteConfig
    private let settings: RemoteConfigSettings

    init(
        remoteConfig: RemoteConfig = RemoteConfig.remoteConfig(),
        settings: RemoteConfigSettings = RemoteConfigSettings()
    ) {
        self.remoteConfig = remoteConfig
        self.settings = settings
        self.settings.minimumFetchInterval = 0
        self.remoteConfig.configSettings = self.settings
    }

    func fetchRemoteConfig() async throws -> RemoteConfigDTO {
        try await remoteConfig.fetch()
        return try await activateRemoteConfig()
    }

    func observeRemoteConfigUpdates() -> AsyncStream<RemoteConfigDTO> {
        AsyncStream { continuation in
            let activationTaskStore = RemoteConfigActivationTaskStore()
            let registration = remoteConfig.addOnConfigUpdateListener { [weak self] _, error in
                guard let self else {
                    return
                }

                if let error {
                    print("Failed to observe remote config updates: \(error)")
                    return
                }

                let task = Task {
                    do {
                        let config = try await self.activateRemoteConfig()
                        guard !Task.isCancelled else {
                            return
                        }
                        continuation.yield(config)
                    } catch {
                        guard !Task.isCancelled else {
                            return
                        }
                        print("Failed to activate remote config update: \(error)")
                    }
                }
                activationTaskStore.replace(with: task)
            }

            continuation.onTermination = { _ in
                registration.remove()
                activationTaskStore.cancel()
            }
        }
    }

    private func activateRemoteConfig() async throws -> RemoteConfigDTO {
        try await remoteConfig.activate()

        return RemoteConfigDTO(
            festivalFeatureEnabled: remoteConfig["festivalFeatureEnabled"].boolValue,
            festivalAppIconEnabled: remoteConfig["festivalAppIconEnabled"].boolValue
        )
    }
}

private final class RemoteConfigActivationTaskStore {
    private let lock = NSLock()
    private var task: Task<Void, Never>?

    func replace(with newTask: Task<Void, Never>) {
        lock.lock()
        task?.cancel()
        task = newTask
        lock.unlock()
    }

    func cancel() {
        lock.lock()
        task?.cancel()
        task = nil
        lock.unlock()
    }
}
