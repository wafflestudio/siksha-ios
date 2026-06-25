//
//  UseCaseProvider.swift
//  Siksha
//
//  Created by Codex on 6/18/26.
//

final class UseCaseProvider {
    let userPreferenceUseCase: UserPreferenceUseCase
    let fetchMyReviewsUseCase: FetchMyReviewsUseCase
    let deleteMyReviewUseCase: DeleteMyReviewUseCase
    let mealInfoUseCase: MealInfoUseCase
    let fetchMealReviewsUseCase: FetchMealReviewsUseCase
    let fetchMealImageReviewsUseCase: FetchMealImageReviewsUseCase
    let fetchMealReviewScoreDistributionUseCase: FetchMealReviewScoreDistributionUseCase
    let fetchMealReviewKeywordDistributionUseCase: FetchMealReviewKeywordDistributionUseCase
    let fetchReviewCommentRecommendationUseCase: FetchReviewCommentRecommendationUseCase
    let submitMealReviewUseCase: SubmitMealReviewUseCase
    let editMealReviewUseCase: EditMealReviewUseCase
    let updateReviewLikeUseCase: UpdateReviewLikeUseCase
    let menuPreferenceUseCase: MenuPreferenceUseCase
    let myLikedMenuUseCase: MyLikedMenuUseCase
    let menuAlarmUseCase: MenuAlarmUseCase

    init(
        userPreferenceUseCase: UserPreferenceUseCase? = nil,
        fetchMyReviewsUseCase: FetchMyReviewsUseCase? = nil,
        deleteMyReviewUseCase: DeleteMyReviewUseCase? = nil,
        mealInfoUseCase: MealInfoUseCase? = nil,
        fetchMealReviewsUseCase: FetchMealReviewsUseCase? = nil,
        fetchMealImageReviewsUseCase: FetchMealImageReviewsUseCase? = nil,
        fetchMealReviewScoreDistributionUseCase: FetchMealReviewScoreDistributionUseCase? = nil,
        fetchMealReviewKeywordDistributionUseCase: FetchMealReviewKeywordDistributionUseCase? = nil,
        fetchReviewCommentRecommendationUseCase: FetchReviewCommentRecommendationUseCase? = nil,
        submitMealReviewUseCase: SubmitMealReviewUseCase? = nil,
        editMealReviewUseCase: EditMealReviewUseCase? = nil,
        updateReviewLikeUseCase: UpdateReviewLikeUseCase? = nil,
        menuPreferenceUseCase: MenuPreferenceUseCase? = nil,
        myLikedMenuUseCase: MyLikedMenuUseCase? = nil,
        menuAlarmUseCase: MenuAlarmUseCase? = nil
    ) {
        let userPreferenceRepository = UserPreferenceRepositoryImpl()
        let myReviewRepository = MyReviewRepositoryImpl()
        let mealInfoRepository = MealInfoRepositoryImpl()
        let menuPreferenceRepository = MenuPreferenceRepositoryImpl()
        let myLikedMenuRepository = MyLikedMenuRepositoryImpl()

        self.userPreferenceUseCase = userPreferenceUseCase ?? DefaultUserPreferenceUseCase(
            repository: userPreferenceRepository
        )
        self.fetchMyReviewsUseCase = fetchMyReviewsUseCase ?? DefaultFetchMyReviewsUseCase(
            repository: myReviewRepository
        )
        self.deleteMyReviewUseCase = deleteMyReviewUseCase ?? DefaultDeleteMyReviewUseCase(
            repository: myReviewRepository
        )
        self.mealInfoUseCase = mealInfoUseCase ?? DefaultMealInfoUseCase(
            repository: mealInfoRepository
        )
        self.fetchMealReviewsUseCase = fetchMealReviewsUseCase ?? DefaultFetchMealReviewsUseCase(
            repository: mealInfoRepository
        )
        self.fetchMealImageReviewsUseCase = fetchMealImageReviewsUseCase ?? DefaultFetchMealImageReviewsUseCase(
            repository: mealInfoRepository
        )
        self.fetchMealReviewScoreDistributionUseCase = fetchMealReviewScoreDistributionUseCase ?? DefaultFetchMealReviewScoreDistributionUseCase(
            repository: mealInfoRepository
        )
        self.fetchMealReviewKeywordDistributionUseCase = fetchMealReviewKeywordDistributionUseCase ?? DefaultFetchMealReviewKeywordDistributionUseCase(
            repository: mealInfoRepository
        )
        self.fetchReviewCommentRecommendationUseCase = fetchReviewCommentRecommendationUseCase ?? DefaultFetchReviewCommentRecommendationUseCase(
            repository: mealInfoRepository
        )
        self.submitMealReviewUseCase = submitMealReviewUseCase ?? DefaultSubmitMealReviewUseCase(
            repository: mealInfoRepository
        )
        self.editMealReviewUseCase = editMealReviewUseCase ?? DefaultEditMealReviewUseCase(
            repository: mealInfoRepository
        )
        self.updateReviewLikeUseCase = updateReviewLikeUseCase ?? DefaultUpdateReviewLikeUseCase(
            repository: mealInfoRepository
        )
        self.menuPreferenceUseCase = menuPreferenceUseCase ?? DefaultMenuPreferenceUseCase(
            repository: menuPreferenceRepository
        )
        self.myLikedMenuUseCase = myLikedMenuUseCase ?? DefaultMyLikedMenuUseCase(
            repository: myLikedMenuRepository
        )
        self.menuAlarmUseCase = menuAlarmUseCase ?? DefaultMenuAlarmUseCase(
            repository: myLikedMenuRepository
        )
    }
}
