//
//  FetchFestivalDatesUseCase.swift
//  Siksha
//
//  Created by Codex on 6/30/26.
//

import Foundation

protocol FetchFestivalDatesUseCase {
    func execute() async throws -> [Date]
}

final class DefaultFetchFestivalDatesUseCase: FetchFestivalDatesUseCase {
    private let repository: FestivalRepositoryProtocol

    init(repository: FestivalRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Date] {
        try await repository.fetchFestivalDates()
    }
}
