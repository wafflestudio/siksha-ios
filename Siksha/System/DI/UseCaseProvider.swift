//
//  UseCaseProvider.swift
//  Siksha
//
//  Created by Codex on 6/18/26.
//

final class UseCaseProvider {
    let userPreferenceUseCase: UserPreferenceUseCase
    let myReviewUseCase: MyReviewUseCase
    let mealInfoUseCase: MealInfoUseCase
    let mealReviewUseCase: MealReviewUseCase

    init(
        userPreferenceUseCase: UserPreferenceUseCase = DefaultUserPreferenceUseCase(
            repository: UserPreferenceRepositoryImpl()
        ),
        myReviewUseCase: MyReviewUseCase = DefaultMyReviewUseCase(
            repository: MyReviewRepositoryImpl()
        ),
        mealInfoUseCase: MealInfoUseCase = DefaultMealInfoUseCase(
            repository: MealInfoRepositoryImpl()
        ),
        mealReviewUseCase: MealReviewUseCase = DefaultMealReviewUseCase(
            repository: MealInfoRepositoryImpl()
        )
    ) {
        self.userPreferenceUseCase = userPreferenceUseCase
        self.myReviewUseCase = myReviewUseCase
        self.mealInfoUseCase = mealInfoUseCase
        self.mealReviewUseCase = mealReviewUseCase
    }
}
