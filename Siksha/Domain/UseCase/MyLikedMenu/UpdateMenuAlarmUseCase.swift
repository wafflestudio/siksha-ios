//
//  UpdateMenuAlarmUseCase.swift
//  Siksha
//
//  Created by Codex on 6/29/26.
//

protocol UpdateMenuAlarmUseCase {
    func execute(menuId: Int, isEnabled: Bool) async throws
}

final class DefaultUpdateMenuAlarmUseCase: UpdateMenuAlarmUseCase {
    private let repository: MyLikedMenuRepositoryProtocol

    init(repository: MyLikedMenuRepositoryProtocol) {
        self.repository = repository
    }

    func execute(menuId: Int, isEnabled: Bool) async throws {
        if isEnabled {
            try await repository.enableMenuAlarm(menuId: menuId)
        } else {
            try await repository.disableMenuAlarm(menuId: menuId)
        }
    }
}
