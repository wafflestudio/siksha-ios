//
//  AppVersionRepositoryImpl.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

final class AppVersionRepositoryImpl: AppVersionRepositoryProtocol {
    private let remote: AppVersionRemoteDataSource

    init(remote: AppVersionRemoteDataSource) {
        self.remote = remote
    }

    func fetchLatestAppStoreVersion() async throws -> AppVersion {
        guard let version = try await remote.fetchLatestAppStoreVersion().results.first?.version,
            !version.isEmpty
        else {
            throw NetworkError.decodingError
        }

        guard let appVersion = AppVersion(rawValue: version) else {
            throw NetworkError.decodingError
        }

        return appVersion
    }
}
