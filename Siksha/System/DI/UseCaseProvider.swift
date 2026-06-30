//
//  UseCaseProvider.swift
//  Siksha
//
//  Created by Codex on 6/18/26.
//

final class UseCaseProvider {
    let userPreferenceUseCase: UserPreferenceUseCase
    let fetchDailyMenuUseCase: FetchDailyMenuUseCase
    let fetchFestivalDatesUseCase: FetchFestivalDatesUseCase
    let fetchRemoteConfigUseCase: FetchRemoteConfigUseCase
    let observeRemoteConfigUseCase: ObserveRemoteConfigUseCase
    let fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase
    let updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase
    let setRestaurantOrderUseCase: SetRestaurantOrderUseCase
    let fetchMyReviewsUseCase: FetchMyReviewsUseCase
    let deleteMyReviewUseCase: DeleteMyReviewUseCase
    let fetchMenuUseCase: FetchMenuUseCase
    let fetchMealReviewsUseCase: FetchMealReviewsUseCase
    let fetchMealImageReviewsUseCase: FetchMealImageReviewsUseCase
    let fetchMealReviewScoreDistributionUseCase: FetchMealReviewScoreDistributionUseCase
    let fetchMealReviewKeywordDistributionUseCase: FetchMealReviewKeywordDistributionUseCase
    let fetchReviewCommentRecommendationUseCase: FetchReviewCommentRecommendationUseCase
    let submitMealReviewUseCase: SubmitMealReviewUseCase
    let editMealReviewUseCase: EditMealReviewUseCase
    let updateReviewLikeUseCase: UpdateReviewLikeUseCase
    let updateMenuLikeUseCase: UpdateMenuLikeUseCase
    let fetchMyLikedMenusUseCase: FetchMyLikedMenusUseCase
    let getMenuAlarmEnabledUseCase: GetMenuAlarmEnabledUseCase
    let setMenuAlarmEnabledUseCase: SetMenuAlarmEnabledUseCase
    let updateMenuAlarmUseCase: UpdateMenuAlarmUseCase
    let updateAllMenuAlarmsUseCase: UpdateAllMenuAlarmsUseCase
    let fetchMenuAlarmTimeUseCase: FetchMenuAlarmTimeUseCase
    let updateMenuAlarmTimeUseCase: UpdateMenuAlarmTimeUseCase

    init(
        userPreferenceUseCase: UserPreferenceUseCase? = nil,
        fetchDailyMenuUseCase: FetchDailyMenuUseCase? = nil,
        fetchFestivalDatesUseCase: FetchFestivalDatesUseCase? = nil,
        fetchRemoteConfigUseCase: FetchRemoteConfigUseCase? = nil,
        observeRemoteConfigUseCase: ObserveRemoteConfigUseCase? = nil,
        fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase? = nil,
        updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase? = nil,
        setRestaurantOrderUseCase: SetRestaurantOrderUseCase? = nil,
        fetchMyReviewsUseCase: FetchMyReviewsUseCase? = nil,
        deleteMyReviewUseCase: DeleteMyReviewUseCase? = nil,
        fetchMenuUseCase: FetchMenuUseCase? = nil,
        fetchMealReviewsUseCase: FetchMealReviewsUseCase? = nil,
        fetchMealImageReviewsUseCase: FetchMealImageReviewsUseCase? = nil,
        fetchMealReviewScoreDistributionUseCase: FetchMealReviewScoreDistributionUseCase? = nil,
        fetchMealReviewKeywordDistributionUseCase: FetchMealReviewKeywordDistributionUseCase? = nil,
        fetchReviewCommentRecommendationUseCase: FetchReviewCommentRecommendationUseCase? = nil,
        submitMealReviewUseCase: SubmitMealReviewUseCase? = nil,
        editMealReviewUseCase: EditMealReviewUseCase? = nil,
        updateReviewLikeUseCase: UpdateReviewLikeUseCase? = nil,
        updateMenuLikeUseCase: UpdateMenuLikeUseCase? = nil,
        fetchMyLikedMenusUseCase: FetchMyLikedMenusUseCase? = nil,
        getMenuAlarmEnabledUseCase: GetMenuAlarmEnabledUseCase? = nil,
        setMenuAlarmEnabledUseCase: SetMenuAlarmEnabledUseCase? = nil,
        updateMenuAlarmUseCase: UpdateMenuAlarmUseCase? = nil,
        updateAllMenuAlarmsUseCase: UpdateAllMenuAlarmsUseCase? = nil,
        fetchMenuAlarmTimeUseCase: FetchMenuAlarmTimeUseCase? = nil,
        updateMenuAlarmTimeUseCase: UpdateMenuAlarmTimeUseCase? = nil
    ) {
        let userPreferenceRepository = UserPreferenceRepositoryImpl()
        let menuRepository = MenuRepositoryImpl()
        let festivalRepository = FestivalRepositoryImpl()
        let remoteConfigRepository = RemoteConfigRepositoryImpl()
        let restaurantRepository = RestaurantRepositoryImpl()
        let myReviewRepository = MyReviewRepositoryImpl()
        let mealInfoRepository = MealInfoRepositoryImpl()
        let menuPreferenceRepository = MenuPreferenceRepositoryImpl()
        let myLikedMenuRepository = MyLikedMenuRepositoryImpl()

        self.userPreferenceUseCase = userPreferenceUseCase ?? DefaultUserPreferenceUseCase(
            repository: userPreferenceRepository
        )
        self.fetchDailyMenuUseCase = fetchDailyMenuUseCase ?? DefaultFetchDailyMenuUseCase(
            repository: menuRepository
        )
        self.fetchFestivalDatesUseCase = fetchFestivalDatesUseCase ?? DefaultFetchFestivalDatesUseCase(
            repository: festivalRepository
        )
        self.fetchRemoteConfigUseCase = fetchRemoteConfigUseCase ?? DefaultFetchRemoteConfigUseCase(
            repository: remoteConfigRepository
        )
        self.observeRemoteConfigUseCase = observeRemoteConfigUseCase ?? DefaultObserveRemoteConfigUseCase(
            repository: remoteConfigRepository
        )
        self.fetchPersonalRestaurantsUseCase = fetchPersonalRestaurantsUseCase ?? DefaultFetchPersonalRestaurantsUseCase(
            repository: restaurantRepository
        )
        self.updateRestaurantPreferenceUseCase = updateRestaurantPreferenceUseCase ?? DefaultUpdateRestaurantPreferenceUseCase(
            repository: restaurantRepository
        )
        self.setRestaurantOrderUseCase = setRestaurantOrderUseCase ?? DefaultSetRestaurantOrderUseCase(
            repository: restaurantRepository
        )
        self.fetchMyReviewsUseCase = fetchMyReviewsUseCase ?? DefaultFetchMyReviewsUseCase(
            repository: myReviewRepository
        )
        self.deleteMyReviewUseCase = deleteMyReviewUseCase ?? DefaultDeleteMyReviewUseCase(
            repository: myReviewRepository
        )
        self.fetchMenuUseCase = fetchMenuUseCase ?? DefaultFetchMenuUseCase(
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
        self.fetchMyLikedMenusUseCase = fetchMyLikedMenusUseCase ?? DefaultFetchMyLikedMenusUseCase(
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
