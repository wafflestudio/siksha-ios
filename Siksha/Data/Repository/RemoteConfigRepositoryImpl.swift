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
}
