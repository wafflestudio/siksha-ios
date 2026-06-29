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
    let updateMenuLikeUseCase: UpdateMenuLikeUseCase
    let myLikedMenuUseCase: MyLikedMenuUseCase
    let getMenuAlarmEnabledUseCase: GetMenuAlarmEnabledUseCase
    let setMenuAlarmEnabledUseCase: SetMenuAlarmEnabledUseCase
    let updateMenuAlarmUseCase: UpdateMenuAlarmUseCase
    let updateAllMenuAlarmsUseCase: UpdateAllMenuAlarmsUseCase
    let fetchMenuAlarmTimeUseCase: FetchMenuAlarmTimeUseCase
    let updateMenuAlarmTimeUseCase: UpdateMenuAlarmTimeUseCase

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
        updateMenuLikeUseCase: UpdateMenuLikeUseCase? = nil,
        myLikedMenuUseCase: MyLikedMenuUseCase? = nil,
        getMenuAlarmEnabledUseCase: GetMenuAlarmEnabledUseCase? = nil,
        setMenuAlarmEnabledUseCase: SetMenuAlarmEnabledUseCase? = nil,
        updateMenuAlarmUseCase: UpdateMenuAlarmUseCase? = nil,
        updateAllMenuAlarmsUseCase: UpdateAllMenuAlarmsUseCase? = nil,
        fetchMenuAlarmTimeUseCase: FetchMenuAlarmTimeUseCase? = nil,
        updateMenuAlarmTimeUseCase: UpdateMenuAlarmTimeUseCase? = nil
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
        self.updateMenuLikeUseCase = updateMenuLikeUseCase ?? DefaultUpdateMenuLikeUseCase(
            repository: menuPreferenceRepository
        )
        self.myLikedMenuUseCase = myLikedMenuUseCase ?? DefaultMyLikedMenuUseCase(
            repository: myLikedMenuRepository
        )
        self.getMenuAlarmEnabledUseCase = getMenuAlarmEnabledUseCase ?? DefaultGetMenuAlarmEnabledUseCase(
            repository: myLikedMenuRepository
        )
        self.setMenuAlarmEnabledUseCase = setMenuAlarmEnabledUseCase ?? DefaultSetMenuAlarmEnabledUseCase(
            repository: myLikedMenuRepository
        )
        self.updateMenuAlarmUseCase = updateMenuAlarmUseCase ?? DefaultUpdateMenuAlarmUseCase(
            repository: myLikedMenuRepository
        )
        self.updateAllMenuAlarmsUseCase = updateAllMenuAlarmsUseCase ?? DefaultUpdateAllMenuAlarmsUseCase(
            repository: myLikedMenuRepository
        )
        self.fetchMenuAlarmTimeUseCase = fetchMenuAlarmTimeUseCase ?? DefaultFetchMenuAlarmTimeUseCase(
            repository: myLikedMenuRepository
        )
        self.updateMenuAlarmTimeUseCase = updateMenuAlarmTimeUseCase ?? DefaultUpdateMenuAlarmTimeUseCase(
            repository: myLikedMenuRepository
        )
    }
}
