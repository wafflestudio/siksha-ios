//
//  UseCaseProvider.swift
//  Siksha
//
//  Created by Codex on 6/18/26.
//

final class UseCaseProvider {
    let loginUseCase: LoginUseCase
    let refreshAccessTokenUseCase: RefreshAccessTokenUseCase
    let resolveInitialAuthStateUseCase: ResolveInitialAuthStateUseCase
    let registerUserDeviceUseCase: RegisterUserDeviceUseCase
    let logoutUseCase: LogoutUseCase
    let deleteAccountUseCase: DeleteAccountUseCase
    let fetchCurrentUserUseCase: FetchCurrentUserUseCase
    let updateUserProfileUseCase: UpdateUserProfileUseCase
    let submitVOCUseCase: SubmitVOCUseCase
    let fetchAppStoreVersionUseCase: FetchAppStoreVersionUseCase
    let checkAppUpdateRequirementUseCase: CheckAppUpdateRequirementUseCase
    let manageMenuFiltersUseCase: ManageMenuFiltersUseCase
    let manageRestaurantsWithoutMenuVisibilityUseCase: ManageRestaurantsWithoutMenuVisibilityUseCase
    let manageFestivalPreferencesUseCase: ManageFestivalPreferencesUseCase
    let checkFestivalSwitchVisibilityUseCase: CheckFestivalSwitchVisibilityUseCase
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
        pushMessagingTokenService: PushMessagingTokenServiceProtocol,
        loginUseCase: LoginUseCase? = nil,
        refreshAccessTokenUseCase: RefreshAccessTokenUseCase? = nil,
        resolveInitialAuthStateUseCase: ResolveInitialAuthStateUseCase? = nil,
        deviceTokenLifecycle: DeviceTokenLifecycle? = nil,
        registerUserDeviceUseCase: RegisterUserDeviceUseCase? = nil,
        logoutUseCase: LogoutUseCase? = nil,
        deleteAccountUseCase: DeleteAccountUseCase? = nil,
        fetchCurrentUserUseCase: FetchCurrentUserUseCase? = nil,
        updateUserProfileUseCase: UpdateUserProfileUseCase? = nil,
        submitVOCUseCase: SubmitVOCUseCase? = nil,
        fetchAppStoreVersionUseCase: FetchAppStoreVersionUseCase? = nil,
        checkAppUpdateRequirementUseCase: CheckAppUpdateRequirementUseCase? = nil,
        manageMenuFiltersUseCase: ManageMenuFiltersUseCase? = nil,
        manageRestaurantsWithoutMenuVisibilityUseCase: ManageRestaurantsWithoutMenuVisibilityUseCase? = nil,
        manageFestivalPreferencesUseCase: ManageFestivalPreferencesUseCase? = nil,
        checkFestivalSwitchVisibilityUseCase: CheckFestivalSwitchVisibilityUseCase? = nil,
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
        let userPreferenceRepository = UserPreferenceRepositoryImpl(
            localDataSource: UserDefaultsUserPreferenceLocalDataSource()
        )
        let menuRepository = MenuRepositoryImpl(
            remote: MenuRemoteDataSourceImpl(),
            local: MenuLocalDataSourceImpl()
        )
        let festivalRepository = FestivalRepositoryImpl(
            remote: FestivalRemoteDataSourceImpl()
        )
        let remoteConfigRepository = RemoteConfigRepositoryImpl(
            dataSource: FirebaseRemoteConfigDataSource()
        )
        let restaurantRepository = RestaurantRepositoryImpl(
            remote: RestaurantRemoteDataSourceImpl(),
            local: RestaurantLocalDataSourceImpl()
        )
        let myReviewRepository = MyReviewRepositoryImpl(
            remote: MyReviewRemoteDataSourceImpl()
        )
        let mealInfoRepository = MealInfoRepositoryImpl(
            remote: MealInfoRemoteDataSourceImpl()
        )
        let menuPreferenceRepository = MenuPreferenceRepositoryImpl(
            remote: MenuPreferenceRemoteDataSourceImpl()
        )
        let myLikedMenuRepository = MyLikedMenuRepositoryImpl(
            remote: MyLikedMenuRemoteDataSourceImpl(),
            local: UserDefaultsMenuAlarmLocalDataSource()
        )
        let deviceTokenRepository = DeviceTokenRepositoryImpl(
            remote: DeviceTokenRemoteDataSourceImpl(),
            local: UserDefaultsDeviceTokenLocalDataSource()
        )
        let authSessionLocalDataSource = AuthSessionLocalDataSourceImpl()
        let authRepository = AuthRepositoryImpl(
            remote: AuthRemoteDataSourceImpl(),
            local: authSessionLocalDataSource
        )
        let appleCredentialRepository = AppleCredentialRepositoryImpl(
            service: AppleCredentialServiceImpl()
        )
        let userRepository = UserRepositoryImpl(
            remote: UserRemoteDataSourceImpl()
        )
        let appVersionRepository = AppVersionRepositoryImpl(
            remote: AppVersionRemoteDataSourceImpl()
        )
        let versionPolicyRepository = VersionPolicyRepositoryImpl(
            remote: VersionPolicyRemoteDataSourceImpl()
        )
        let defaultRefreshAccessTokenUseCase =
            refreshAccessTokenUseCase
            ?? DefaultRefreshAccessTokenUseCase(
                repository: authRepository
            )
        let defaultSetMenuAlarmEnabledUseCase =
            setMenuAlarmEnabledUseCase
            ?? DefaultSetMenuAlarmEnabledUseCase(
                repository: myLikedMenuRepository
            )
        let defaultDeviceTokenLifecycle =
            deviceTokenLifecycle
            ?? DefaultDeviceTokenLifecycle(
                deviceTokenRepository: deviceTokenRepository,
                authRepository: authRepository
            )
        let defaultRegisterUserDeviceUseCase =
            registerUserDeviceUseCase
            ?? DefaultRegisterUserDeviceUseCase(
                lifecycle: defaultDeviceTokenLifecycle
            )
        let accountLocalStateCleaner = DefaultAccountLocalStateCleaner(
            messagingTokenService: pushMessagingTokenService,
            deviceTokenRepository: deviceTokenRepository,
            authRepository: authRepository,
            menuAlarmPreferenceRepository: myLikedMenuRepository,
            personalRestaurantStateRepository: restaurantRepository
        )

        self.loginUseCase =
            loginUseCase
            ?? DefaultLoginUseCase(
                repository: authRepository
            )
        self.refreshAccessTokenUseCase = defaultRefreshAccessTokenUseCase
        self.resolveInitialAuthStateUseCase =
            resolveInitialAuthStateUseCase
            ?? DefaultResolveInitialAuthStateUseCase(
                authRepository: authRepository,
                refreshAccessTokenUseCase: defaultRefreshAccessTokenUseCase,
                appleCredentialRepository: appleCredentialRepository
            )
        self.registerUserDeviceUseCase = defaultRegisterUserDeviceUseCase
        self.logoutUseCase =
            logoutUseCase
            ?? DefaultLogoutUseCase(
                deviceTokenLifecycle: defaultDeviceTokenLifecycle,
                accountLocalStateCleaner: accountLocalStateCleaner
            )
        self.deleteAccountUseCase =
            deleteAccountUseCase
            ?? DefaultDeleteAccountUseCase(
                deviceTokenLifecycle: defaultDeviceTokenLifecycle,
                userRepository: userRepository,
                accountLocalStateCleaner: accountLocalStateCleaner
            )
        self.fetchCurrentUserUseCase =
            fetchCurrentUserUseCase
            ?? DefaultFetchCurrentUserUseCase(
                repository: userRepository
            )
        self.updateUserProfileUseCase =
            updateUserProfileUseCase
            ?? DefaultUpdateUserProfileUseCase(
                repository: userRepository
            )
        self.submitVOCUseCase =
            submitVOCUseCase
            ?? DefaultSubmitVOCUseCase(
                repository: userRepository
            )
        self.fetchAppStoreVersionUseCase =
            fetchAppStoreVersionUseCase
            ?? DefaultFetchAppStoreVersionUseCase(
                repository: appVersionRepository
            )
        self.checkAppUpdateRequirementUseCase =
            checkAppUpdateRequirementUseCase
            ?? DefaultCheckAppUpdateRequirementUseCase(
                repository: versionPolicyRepository
            )
        self.manageMenuFiltersUseCase =
            manageMenuFiltersUseCase
            ?? DefaultManageMenuFiltersUseCase(
                repository: userPreferenceRepository
            )
        self.manageRestaurantsWithoutMenuVisibilityUseCase =
            manageRestaurantsWithoutMenuVisibilityUseCase
            ?? DefaultManageRestaurantsWithoutMenuVisibilityUseCase(
                repository: userPreferenceRepository
            )
        self.manageFestivalPreferencesUseCase =
            manageFestivalPreferencesUseCase
            ?? DefaultManageFestivalPreferencesUseCase(
                repository: userPreferenceRepository
            )
        self.checkFestivalSwitchVisibilityUseCase =
            checkFestivalSwitchVisibilityUseCase ?? DefaultCheckFestivalSwitchVisibilityUseCase()
        self.fetchDailyMenuUseCase =
            fetchDailyMenuUseCase
            ?? DefaultFetchDailyMenuUseCase(
                repository: menuRepository
            )
        self.fetchFestivalDatesUseCase =
            fetchFestivalDatesUseCase
            ?? DefaultFetchFestivalDatesUseCase(
                repository: festivalRepository
            )
        self.fetchRemoteConfigUseCase =
            fetchRemoteConfigUseCase
            ?? DefaultFetchRemoteConfigUseCase(
                repository: remoteConfigRepository
            )
        self.observeRemoteConfigUseCase =
            observeRemoteConfigUseCase
            ?? DefaultObserveRemoteConfigUseCase(
                repository: remoteConfigRepository
            )
        self.fetchPersonalRestaurantsUseCase =
            fetchPersonalRestaurantsUseCase
            ?? DefaultFetchPersonalRestaurantsUseCase(
                repository: restaurantRepository
            )
        self.updateRestaurantPreferenceUseCase =
            updateRestaurantPreferenceUseCase
            ?? DefaultUpdateRestaurantPreferenceUseCase(
                repository: restaurantRepository
            )
        self.setRestaurantOrderUseCase =
            setRestaurantOrderUseCase
            ?? DefaultSetRestaurantOrderUseCase(
                repository: restaurantRepository
            )
        self.fetchMyReviewsUseCase =
            fetchMyReviewsUseCase
            ?? DefaultFetchMyReviewsUseCase(
                repository: myReviewRepository
            )
        self.deleteMyReviewUseCase =
            deleteMyReviewUseCase
            ?? DefaultDeleteMyReviewUseCase(
                repository: myReviewRepository
            )
        self.fetchMenuUseCase =
            fetchMenuUseCase
            ?? DefaultFetchMenuUseCase(
                repository: mealInfoRepository
            )
        self.fetchMealReviewsUseCase =
            fetchMealReviewsUseCase
            ?? DefaultFetchMealReviewsUseCase(
                repository: mealInfoRepository
            )
        self.fetchMealImageReviewsUseCase =
            fetchMealImageReviewsUseCase
            ?? DefaultFetchMealImageReviewsUseCase(
                repository: mealInfoRepository
            )
        self.fetchMealReviewScoreDistributionUseCase =
            fetchMealReviewScoreDistributionUseCase
            ?? DefaultFetchMealReviewScoreDistributionUseCase(
                repository: mealInfoRepository
            )
        self.fetchMealReviewKeywordDistributionUseCase =
            fetchMealReviewKeywordDistributionUseCase
            ?? DefaultFetchMealReviewKeywordDistributionUseCase(
                repository: mealInfoRepository
            )
        self.fetchReviewCommentRecommendationUseCase =
            fetchReviewCommentRecommendationUseCase
            ?? DefaultFetchReviewCommentRecommendationUseCase(
                repository: mealInfoRepository
            )
        self.submitMealReviewUseCase =
            submitMealReviewUseCase
            ?? DefaultSubmitMealReviewUseCase(
                repository: mealInfoRepository
            )
        self.editMealReviewUseCase =
            editMealReviewUseCase
            ?? DefaultEditMealReviewUseCase(
                repository: mealInfoRepository
            )
        self.updateReviewLikeUseCase =
            updateReviewLikeUseCase
            ?? DefaultUpdateReviewLikeUseCase(
                repository: mealInfoRepository
            )
        self.updateMenuLikeUseCase =
            updateMenuLikeUseCase
            ?? DefaultUpdateMenuLikeUseCase(
                repository: menuPreferenceRepository
            )
        self.fetchMyLikedMenusUseCase =
            fetchMyLikedMenusUseCase
            ?? DefaultFetchMyLikedMenusUseCase(
                repository: myLikedMenuRepository
            )
        self.getMenuAlarmEnabledUseCase =
            getMenuAlarmEnabledUseCase
            ?? DefaultGetMenuAlarmEnabledUseCase(
                repository: myLikedMenuRepository
            )
        self.setMenuAlarmEnabledUseCase = defaultSetMenuAlarmEnabledUseCase
        self.updateMenuAlarmUseCase =
            updateMenuAlarmUseCase
            ?? DefaultUpdateMenuAlarmUseCase(
                repository: myLikedMenuRepository
            )
        self.updateAllMenuAlarmsUseCase =
            updateAllMenuAlarmsUseCase
            ?? DefaultUpdateAllMenuAlarmsUseCase(
                repository: myLikedMenuRepository
            )
        self.fetchMenuAlarmTimeUseCase =
            fetchMenuAlarmTimeUseCase
            ?? DefaultFetchMenuAlarmTimeUseCase(
                repository: myLikedMenuRepository
            )
        self.updateMenuAlarmTimeUseCase =
            updateMenuAlarmTimeUseCase
            ?? DefaultUpdateMenuAlarmTimeUseCase(
                repository: myLikedMenuRepository
            )
    }
}
