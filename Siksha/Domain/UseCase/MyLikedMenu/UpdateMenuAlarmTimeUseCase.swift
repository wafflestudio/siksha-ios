//
//  UpdateMenuAlarmTimeUseCase.swift
//  Siksha
//
//  Created by Codex on 6/29/26.
//

protocol UpdateMenuAlarmTimeUseCase {
    func execute(_ alarmTime: AlarmTime) async throws
}

final class DefaultUpdateMenuAlarmTimeUseCase: UpdateMenuAlarmTimeUseCase {
    private let repository: MyLikedMenuRepositoryProtocol

    init(repository: MyLikedMenuRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ alarmTime: AlarmTime) async throws {
        try await repository.updateAlarmTime(alarmTime)
    }
}
