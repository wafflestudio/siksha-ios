//
//  GetMenuAlarmEnabledUseCase.swift
//  Siksha
//
//  Created by Codex on 6/29/26.
//

protocol GetMenuAlarmEnabledUseCase {
    func execute() -> Bool
}

final class DefaultGetMenuAlarmEnabledUseCase: GetMenuAlarmEnabledUseCase {
    private let repository: MyLikedMenuRepositoryProtocol

    init(repository: MyLikedMenuRepositoryProtocol) {
        self.repository = repository
    }

    func execute() -> Bool {
        repository.getAlarmEnabled()
    }
}
