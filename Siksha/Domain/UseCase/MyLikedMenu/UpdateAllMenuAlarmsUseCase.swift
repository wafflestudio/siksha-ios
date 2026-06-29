//
//  UpdateAllMenuAlarmsUseCase.swift
//  Siksha
//
//  Created by Codex on 6/29/26.
//

protocol UpdateAllMenuAlarmsUseCase {
    func execute(isEnabled: Bool) async throws
}

final class DefaultUpdateAllMenuAlarmsUseCase: UpdateAllMenuAlarmsUseCase {
    private let repository: MyLikedMenuRepositoryProtocol

    init(repository: MyLikedMenuRepositoryProtocol) {
        self.repository = repository
    }

    func execute(isEnabled: Bool) async throws {
        if isEnabled {
            try await repository.enableAllMenuAlarms()
        } else {
            try await repository.disableAllMenuAlarms()
        }

        repository.setAlarmEnabled(isEnabled)
    }
}
