//
//  AppVersionRemoteDataSource.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

protocol AppVersionRemoteDataSource {
    func fetchLatestAppStoreVersion() async throws -> AppVersionLookupResponseDTO
}

final class AppVersionRemoteDataSourceImpl: AppVersionRemoteDataSource {
    private let lookupURL: URL
    private let session: URLSession

    init(
        lookupURL: URL = URL(string: "https://itunes.apple.com/lookup?id=1032700617")!,
        session: URLSession = .shared
    ) {
        self.lookupURL = lookupURL
        self.session = session
    }

    func fetchLatestAppStoreVersion() async throws -> AppVersionLookupResponseDTO {
        let (data, response) = try await session.data(from: lookupURL)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.decodingError
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.apiError(
                message: "HTTP \(httpResponse.statusCode)",
                code: "\(httpResponse.statusCode)"
            )
        }

        return try JSONDecoder().decode(AppVersionLookupResponseDTO.self, from: data)
    }
}
