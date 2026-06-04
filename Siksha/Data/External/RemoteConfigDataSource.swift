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
        try await remoteConfig.activate()

        return RemoteConfigDTO(
            festivalFeatureEnabled: remoteConfig["festivalFeatureEnabled"].boolValue,
            festivalAppIconEnabled: remoteConfig["festivalAppIconEnabled"].boolValue
        )
    }
}
