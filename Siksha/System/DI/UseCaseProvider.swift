//
//  UseCaseProvider.swift
//  Siksha
//
//  Created by Codex on 6/18/26.
//

final class UseCaseProvider {
    let userPreferenceUseCase: UserPreferenceUseCase
    let myReviewUseCase: MyReviewUseCase

    init(
        userPreferenceUseCase: UserPreferenceUseCase = DefaultUserPreferenceUseCase(
            repository: UserPreferenceRepositoryImpl()
        ),
        myReviewUseCase: MyReviewUseCase = DefaultMyReviewUseCase(
            repository: MyReviewRepositoryImpl()
        )
    ) {
        self.userPreferenceUseCase = userPreferenceUseCase
        self.myReviewUseCase = myReviewUseCase
    }
}
