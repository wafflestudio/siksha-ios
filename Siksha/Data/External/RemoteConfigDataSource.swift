//
//  RemoteConfigDataSource.swift
//  Siksha
//
//  Created by Codex on 6/4/26.
//

import FirebaseRemoteConfig
import Foundation

protocol RemoteConfigDataSource: Sendable {
    func fetchRemoteConfig() async throws -> RemoteConfigDTO
    func observeRemoteConfigUpdates() async -> AsyncStream<RemoteConfigDTO>
}

actor FirebaseRemoteConfigDataSource: RemoteConfigDataSource {
    private let remoteConfig: RemoteConfig
    private var activeObservations: Set<UUID> = []
    private var activationTasks: [UUID: Task<Void, Never>] = [:]

    init() {
        let remoteConfig = RemoteConfig.remoteConfig()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        remoteConfig.configSettings = settings
        self.remoteConfig = remoteConfig
    }

    func fetchRemoteConfig() async throws -> RemoteConfigDTO {
        try await remoteConfig.fetch()
        return try await activateRemoteConfig()
    }

    func observeRemoteConfigUpdates() async -> AsyncStream<RemoteConfigDTO> {
        let observationID = UUID()
        let (stream, continuation) = AsyncStream<RemoteConfigDTO>.makeStream()
        activeObservations.insert(observationID)

        let registration = remoteConfig.addOnConfigUpdateListener { [weak self] _, error in
            if let error {
                print("Failed to observe remote config updates: \(error)")
                return
            }

            Task {
                await self?.replaceActivationTask(
                    for: observationID,
                    continuation: continuation
                )
            }
        }

        continuation.onTermination = { [weak self] _ in
            registration.remove()
            Task {
                await self?.stopObservation(observationID)
            }
        }

        return stream
    }

    private func replaceActivationTask(
        for observationID: UUID,
        continuation: AsyncStream<RemoteConfigDTO>.Continuation
    ) {
        guard activeObservations.contains(observationID) else {
            return
        }

        activationTasks[observationID]?.cancel()
        activationTasks[observationID] = Task {
            do {
                let config = try await activateRemoteConfig()
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
    }

    private func stopObservation(_ observationID: UUID) {
        activeObservations.remove(observationID)
        activationTasks.removeValue(forKey: observationID)?.cancel()
    }

    private func activateRemoteConfig() async throws -> RemoteConfigDTO {
        try await remoteConfig.activate()

        return RemoteConfigDTO(
            festivalFeatureEnabled: remoteConfig["festivalFeatureEnabled"].boolValue,
            festivalAppIconEnabled: remoteConfig["festivalAppIconEnabled"].boolValue
        )
    }
}
