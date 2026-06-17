//
//  UseCaseProvider.swift
//  Siksha
//
//  Created by Codex on 6/18/26.
//

final class UseCaseProvider {
    let userPreferenceUseCase: UserPreferenceUseCase

    init(
        userPreferenceUseCase: UserPreferenceUseCase = DefaultUserPreferenceUseCase(
            repository: UserPreferenceRepositoryImpl()
        )
    ) {
        self.userPreferenceUseCase = userPreferenceUseCase
    }
}
