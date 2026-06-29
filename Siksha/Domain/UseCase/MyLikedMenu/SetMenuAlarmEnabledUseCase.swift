//
//  SetMenuAlarmEnabledUseCase.swift
//  Siksha
//
//  Created by Codex on 6/29/26.
//

protocol SetMenuAlarmEnabledUseCase {
    func execute(_ isEnabled: Bool)
}

final class DefaultSetMenuAlarmEnabledUseCase: SetMenuAlarmEnabledUseCase {
    private let repository: MyLikedMenuRepositoryProtocol

    init(repository: MyLikedMenuRepositoryProtocol) {
        self.repository = repository
    }

    func execute(_ isEnabled: Bool) {
        repository.setAlarmEnabled(isEnabled)
    }
}
