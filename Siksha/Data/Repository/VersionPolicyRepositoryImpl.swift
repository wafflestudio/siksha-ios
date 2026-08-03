//
//  VersionPolicyRepositoryImpl.swift
//  Siksha
//

final class VersionPolicyRepositoryImpl: VersionPolicyRepositoryProtocol {
    private let remote: VersionPolicyRemoteDataSource

    init(remote: VersionPolicyRemoteDataSource) {
        self.remote = remote
    }

    func fetchMinimumSupportedVersion() async throws -> AppVersion {
        let response = try await remote.fetchMinimumSupportedVersion()
        guard let version = AppVersion(rawValue: response.minimumVersion) else {
            throw NetworkError.decodingError
        }

        return version
    }
}
