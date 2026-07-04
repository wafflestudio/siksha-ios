//
//  FetchMenuAlarmTimeUseCase.swift
//  Siksha
//
//  Created by Codex on 6/29/26.
//

protocol FetchMenuAlarmTimeUseCase {
    func execute() async throws -> AlarmTime
}

final class DefaultFetchMenuAlarmTimeUseCase: FetchMenuAlarmTimeUseCase {
    private let repository: MyLikedMenuRepositoryProtocol

    init(repository: MyLikedMenuRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> AlarmTime {
        try await repository.fetchAlarmTime()
    }
}
