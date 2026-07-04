//
//  FestivalRepositoryImpl.swift
//  Siksha
//
//  Created by Codex on 6/4/26.
//

import Foundation

final class FestivalRepositoryImpl: FestivalRepositoryProtocol {
    private let remote: FestivalRemoteDataSource

    init(remote: FestivalRemoteDataSource) {
        self.remote = remote
    }

    func fetchFestivalDates() async throws -> [Date] {
        try await remote.fetchFestivalDates().toDomain()
    }
}
