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
    let menuPreferenceUseCase: MenuPreferenceUseCase
    let myLikedMenuUseCase: MyLikedMenuUseCase
    let menuAlarmUseCase: MenuAlarmUseCase

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
        ),
        menuPreferenceUseCase: MenuPreferenceUseCase = DefaultMenuPreferenceUseCase(
            repository: MenuPreferenceRepositoryImpl()
        ),
        myLikedMenuUseCase: MyLikedMenuUseCase = DefaultMyLikedMenuUseCase(
            repository: MyLikedMenuRepositoryImpl()
        ),
        menuAlarmUseCase: MenuAlarmUseCase = DefaultMenuAlarmUseCase(
            repository: MyLikedMenuRepositoryImpl()
        )
    ) {
        self.userPreferenceUseCase = userPreferenceUseCase
        self.myReviewUseCase = myReviewUseCase
        self.mealInfoUseCase = mealInfoUseCase
        self.mealReviewUseCase = mealReviewUseCase
        self.menuPreferenceUseCase = menuPreferenceUseCase
        self.myLikedMenuUseCase = myLikedMenuUseCase
        self.menuAlarmUseCase = menuAlarmUseCase
    }
}
