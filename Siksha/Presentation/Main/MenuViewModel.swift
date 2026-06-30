//
//  MenuViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import UIKit
import Combine
import CoreLocation

final class MenuViewModel: NSObject, ObservableObject {
    let analytics: AnalyticsService

    private var festivalDates: [Date] = []
    
    private let MAX_PRICE = 10000
    private var cancellables = Set<AnyCancellable>()
    
    private let fetchDailyMenuUseCase: FetchDailyMenuUseCase
    private let fetchFestivalDatesUseCase: FetchFestivalDatesUseCase
    private let fetchRemoteConfigUseCase: FetchRemoteConfigUseCase
    private let observeRemoteConfigUseCase: ObserveRemoteConfigUseCase
    private let fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase
    private let updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase
    private let mealSectionRenderScheduler: MealSectionRenderScheduling
    private let userPreferenceUseCase: UserPreferenceUseCase
    private let formatter = DateFormatter()
    private let locationManager = CLLocationManager()
    private var remoteConfigFetchTask: Task<Void, Never>?
    private var remoteConfigUpdatesTask: Task<Void, Never>?
    private var personalRestaurantById: [Int: PersonalRestaurantModel] = [:]
    private var personalRestaurantOrder: [Int: Int] = [:]
    private var updatingLikeRestaurantIds = Set<Int>()
    private var isLoadingPersonalRestaurants = false
    private var shouldUseDefaultRestaurantPreference = false
    
    @Published var showCalendar: Bool = false
    @Published var showFestivalSwitch: Bool = false
    
    @Published var selectedDate: String
    @Published var nextDate: String = ""
    @Published var prevDate: String = ""
    
    @Published var selectedFormatted: String = ""
    
    private var currentDailyMenu: DailyMenuModel? = nil
    @Published var selectedFilters: MenuFilters = MenuFilters()
    @Published var mealSections: [MealSectionDisplayModel] = []
    
    @Published var getMenuStatus: MenuStatus = .idle
    
    @Published var showNetworkAlert: Bool = false
    @Published var showDistanceAlert: Bool = false
    
    @Published var selectedPage: Int = 0
    
    @Published var reloadOnAppear: Bool = true
    
    @Published var isFestivalAvailable: Bool
    @Published private(set) var isFestivalSwitchOn: Bool = false
    @Published var isFestivalAppIconEnabled: Bool
    
    @Published var menuList: [DailyMenuModel] = []
    
    private let dateRange: CurrentValueSubject<(start: String, end: String), Never>
    
    private var todayString: String {
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    private var tommorowString: String {
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date(timeIntervalSinceNow: 60 * 60 * 24))
    }
    
    var priceLabel:String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        if let priceRange = selectedFilters.priceRange {
            let formattedLower = numberFormatter.string(from: NSNumber(value: priceRange.lowerBound))!
            let formattedUpper = numberFormatter.string(from: NSNumber(value: priceRange.upperBound))!
            if priceRange.upperBound == MAX_PRICE{
                return "\(formattedLower)원 ~ \(formattedUpper)원 이상"
            } else {
                return "\(formattedLower)원 ~ \(formattedUpper)원"
            }
        }
        return "가격"
    }
    var distanceLabel:String{
        if let distance = selectedFilters.distance {
            return "\(distance)m 이내"
        }
        return "거리"
    }
    var minRatingLabel:String{
        if let minimumRating = selectedFilters.minimumRating {
            return "평점 \(minimumRating) 이상"
        }
        return "최소 평점"
    }
    var categoryLabel:String{
        if let categories = selectedFilters.categories {
            return categories.joined(separator: ",")
        }
        return "카테고리"
    }

    var currentOperatingHourType: Int {
        currentDailyMenu?.dateType.operatingHourType ?? 0
    }
    
    init(
        analytics: AnalyticsService = MixpanelAnalytics(),
        fetchDailyMenuUseCase: FetchDailyMenuUseCase,
        fetchFestivalDatesUseCase: FetchFestivalDatesUseCase,
        fetchRemoteConfigUseCase: FetchRemoteConfigUseCase,
        observeRemoteConfigUseCase: ObserveRemoteConfigUseCase,
        fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase,
        updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase,
        mealSectionRenderScheduler: MealSectionRenderScheduling = MealSectionRenderScheduler(),
        userPreferenceUseCase: UserPreferenceUseCase
    ) {
        self.analytics = analytics
        self.fetchDailyMenuUseCase = fetchDailyMenuUseCase
        self.fetchFestivalDatesUseCase = fetchFestivalDatesUseCase
        self.fetchRemoteConfigUseCase = fetchRemoteConfigUseCase
        self.observeRemoteConfigUseCase = observeRemoteConfigUseCase
        self.fetchPersonalRestaurantsUseCase = fetchPersonalRestaurantsUseCase
        self.updateRestaurantPreferenceUseCase = updateRestaurantPreferenceUseCase
        self.mealSectionRenderScheduler = mealSectionRenderScheduler
        self.userPreferenceUseCase = userPreferenceUseCase
        
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "yyyy-MM-dd"
        selectedDate = formatter.string(from: Date())
        
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
        dateRange = CurrentValueSubject((formatter.string(from: today), formatter.string(from: tomorrow)))
        
        isFestivalAvailable = userPreferenceUseCase.isFestivalFeatureAvailable()
        isFestivalAppIconEnabled = userPreferenceUseCase.isFestivalAppIconEnabled()
        
        super.init()

        remoteConfigFetchTask = Task { [weak self] in
            await self?.loadRemoteConfig()
        }
        startObservingRemoteConfigUpdates()
        
        isFestivalSwitchOn = isFestivalAvailable && userPreferenceUseCase.isFestivalSwitchOn()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour], from: Date())
        if let hour = components.hour {
            if hour > 16 {
                selectedPage = 2
            } else if hour > 11 {
                selectedPage = 1
            }
        }
        
        loadFilters()
        Task {
            await loadFestivalDates()
        }
        subscribe()
        Task {
            await loadPersonalRestaurants()
        }
    }

    deinit {
        remoteConfigFetchTask?.cancel()
        remoteConfigUpdatesTask?.cancel()
    }
    
    @MainActor
    private func loadRemoteConfig() async {
        do {
            let config = try await fetchRemoteConfigUseCase.execute()
            applyRemoteConfig(config)
        } catch {
            print("Failed to load remote config: \(error)")
        }
    }

    private func startObservingRemoteConfigUpdates() {
        remoteConfigUpdatesTask = Task { [weak self] in
            guard let updates = self?.observeRemoteConfigUseCase.execute() else {
                return
            }

            for await config in updates {
                await self?.applyRemoteConfig(config)
            }
        }
    }

    @MainActor
    private func applyRemoteConfig(_ config: RemoteConfigModel) {
        isFestivalAvailable = config.festivalFeatureEnabled
        userPreferenceUseCase.setFestivalFeatureAvailable(config.festivalFeatureEnabled)
        isFestivalAppIconEnabled = config.festivalAppIconEnabled
        refreshFestivalSwitchState()
    }
    
    private func subscribe() {
        subscribeToIsFestivalAppIconEnabled()
        subscribeToMealSectionRendering()
        subscribeToSelectedDate()
    }
    
    private func subscribeToIsFestivalAppIconEnabled() {
        $isFestivalAppIconEnabled
            .sink { [weak self] enabled in
                guard let self = self else { return }
                self.userPreferenceUseCase.setFestivalAppIconEnabled(enabled)
                
                let desiredIconName: String? = enabled ? "FestivalAppIcon" : nil
                let currentIconName = UIApplication.shared.alternateIconName
                
                if currentIconName != desiredIconName {
                    UIApplication.shared.setAlternateIconName(desiredIconName) { error in
                        if let error = error {
                            print("Failed to set app icon: \(error)")
                        }
                    }
                }
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToSelectedDate() {
        $selectedDate
            .removeDuplicates()
            .sink { [weak self] dateString in
                guard let self = self else { return }
                self.formatter.dateFormat = "yyyy-MM-dd"
                let selected = self.formatter.date(from: dateString) ?? Date()
                
                let next = selected.addingTimeInterval(86400)
                let prev = selected.addingTimeInterval(-86400)
                
                self.formatter.dateFormat = "yyyy-MM-dd"
                self.nextDate = self.formatter.string(from: next)
                self.prevDate = self.formatter.string(from: prev)
                
                self.formatter.dateFormat = "yyyy-MM-dd (E)"
                self.selectedFormatted = self.formatter.string(from: selected)
                
                self.getMenu(date: dateString)
                
                self.refreshFestivalSwitchState(selectedDate: selected)
            }
            .store(in: &cancellables)
    }

    private func subscribeToMealSectionRendering() {
        mealSectionRenderScheduler.mealSectionsPublisher
            .sink { [weak self] mealSections in
                self?.mealSections = mealSections
            }
            .store(in: &cancellables)
    }

    @MainActor
    private func loadPersonalRestaurants() async {
        guard !isLoadingPersonalRestaurants else {
            return
        }
        
        isLoadingPersonalRestaurants = true
        defer {
            isLoadingPersonalRestaurants = false
        }
        
        do {
            let restaurants = try await fetchPersonalRestaurantsUseCase.execute()
            shouldUseDefaultRestaurantPreference = false
            updatePersonalRestaurants(restaurants)
            requestMealSectionRender()
        } catch {
            print("Failed to load personal restaurants: \(error)")

            if personalRestaurantById.isEmpty {
                shouldUseDefaultRestaurantPreference = true
                requestMealSectionRender()
            }
        }
    }
    
    @MainActor
    func refreshPersonalRestaurants() {
        Task {
            await loadPersonalRestaurants()
        }
    }
    
    private func updatePersonalRestaurants(_ restaurants: [PersonalRestaurantModel]) {
        var byId: [Int: PersonalRestaurantModel] = [:]
        var order: [Int: Int] = [:]
        
        for (index, restaurant) in restaurants.enumerated() {
            byId[restaurant.id] = restaurant
            order[restaurant.id] = index
        }
        
        personalRestaurantById = byId
        personalRestaurantOrder = order
        shouldUseDefaultRestaurantPreference = false
    }
    
    private func refreshFestivalSwitchState(selectedDate selected: Date? = nil) {
        let selected = selected ?? currentSelectedDate()
        showFestivalSwitch = isFestivalAvailable && festivalDates.contains(selected)
        if !showFestivalSwitch {
            setFestivalSwitchOn(false, renderTiming: .immediate)
        }
    }

    private func currentSelectedDate() -> Date {
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: selectedDate) ?? Date()
    }
    
    @MainActor
    func toggleRestaurantLike(_ restaurantId: Int) async {
        guard !updatingLikeRestaurantIds.contains(restaurantId),
              let restaurant = personalRestaurantById[restaurantId] else {
            return
        }
        
        updatingLikeRestaurantIds.insert(restaurantId)
        defer {
            updatingLikeRestaurantIds.remove(restaurantId)
        }
        
        do {
            let status = try await updateRestaurantPreferenceUseCase.setLiked(
                restaurant: restaurant,
                liked: !restaurant.liked
            )
            updatePersonalRestaurant(status)
            requestMealSectionRender()
        } catch {
            print("Failed to update restaurant like: \(error)")
        }
    }
    
    private func updatePersonalRestaurant(_ status: RestaurantPreferenceStatusModel) {
        guard let restaurant = personalRestaurantById[status.id] else {
            return
        }
        
        personalRestaurantById[status.id] = PersonalRestaurantModel(
            id: restaurant.id,
            code: restaurant.code,
            nameKr: restaurant.nameKr,
            nameEn: restaurant.nameEn,
            address: restaurant.address,
            coordinate: restaurant.coordinate,
            liked: status.liked,
            visible: status.visible,
            operatingHours: restaurant.operatingHours
        )
    }
    
    func setFestivalSwitchOn(_ isOn: Bool) {
        setFestivalSwitchOn(isOn, renderTiming: .debounced)
    }

    private func setFestivalSwitchOn(_ isOn: Bool, renderTiming: MealSectionRenderTiming) {
        let isOn = showFestivalSwitch && isOn
        guard isFestivalSwitchOn != isOn else {
            return
        }

        isFestivalSwitchOn = isOn
        userPreferenceUseCase.setFestivalSwitchOn(isOn)
        requestMealSectionRender(timing: renderTiming)
    }

    private func requestMealSectionRender(timing: MealSectionRenderTiming = .immediate) {
        guard let input = makeMealSectionRenderInput() else {
            mealSections = []
            mealSectionRenderScheduler.clear()
            return
        }

        mealSectionRenderScheduler.render(input: input, timing: timing)
    }

    private func makeMealSectionRenderInput() -> MealSectionDisplayModelBuilder.Input? {
        guard let currentDailyMenu else {
            return nil
        }

        let noMenuHide = userPreferenceUseCase.shouldHideRestaurantsWithoutMenu()

        return MealSectionDisplayModelBuilder.Input(
            menu: currentDailyMenu,
            filters: selectedFilters,
            personalRestaurantById: personalRestaurantById,
            personalRestaurantOrder: personalRestaurantOrder,
            shouldUseDefaultRestaurantPreference: shouldUseDefaultRestaurantPreference,
            noMenuHide: noMenuHide,
            selectedDate: selectedDate,
            currentLocation: locationManager.location,
            isFestivalSwitchOn: isFestivalSwitchOn
        )
    }
    
    private func checkLocationAuthorization() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
            return
        case .restricted:
            DispatchQueue.main.async { self.showDistanceAlert = true }
            return
        case .denied:
            DispatchQueue.main.async { self.showDistanceAlert = true }
            return
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            return
        @unknown default:
            DispatchQueue.main.async { self.showDistanceAlert = true }
            return
        }
    }

    private func resolveAvailableFilters(_ filters: MenuFilters) -> MenuFilters {
        guard filters.distance != nil else {
            return filters
        }

        checkLocationAuthorization()
        guard locationManager.authorizationStatus == .authorizedAlways ||
              locationManager.authorizationStatus == .authorizedWhenInUse,
              locationManager.location != nil else {
            var resolvedFilters = filters
            resolvedFilters.distance = nil
            showDistanceAlert = true
            return resolvedFilters
        }

        return filters
    }
    
    private func getMenu(date: String) {
        Task { @MainActor [weak self] in
            guard let self else {
                return
            }
            
            guard getMenuStatus != .loading else {
                return
            }
            
            getMenuStatus = .loading
            
            let result = await fetchDailyMenuUseCase.execute(date: date)
            
            guard date == selectedDate else {
                getMenuStatus = .idle
                getMenu(date: selectedDate)
                return
            }
            
            showCalendar = false
            
            switch result {
            case .succeeded(let menu):
                currentDailyMenu = menu
                requestMealSectionRender()
                getMenuStatus = .idle
            case .empty:
                clearCurrentDailyMenu()
                getMenuStatus = .idle
            case .cached(let menu):
                currentDailyMenu = menu
                requestMealSectionRender()
                showNetworkAlert = true
                getMenuStatus = .idle
            case .failed:
                clearCurrentDailyMenu()
                showNetworkAlert = true
                getMenuStatus = .failed
            }
            
            userPreferenceUseCase.setCanSubmitReview(selectedDate == todayString)
        }
    }
    
    func loadFilters() {
        applyFilters(userPreferenceUseCase.menuFilters(), shouldPersist: true)
    }
    
    func updateFilters(_ update: (inout MenuFilters) -> Void) {
        var filters = selectedFilters
        update(&filters)
        setFilters(filters)
    }
    
    func setFilters(_ filters: MenuFilters) {
        applyFilters(filters, shouldPersist: true)
        requestMealSectionRender()
    }
    
    private func applyFilters(_ filters: MenuFilters, shouldPersist: Bool) {
        selectedFilters = resolveAvailableFilters(filters)
        if shouldPersist {
            saveFilters()
        }
    }

    private func saveFilters() {
        userPreferenceUseCase.saveMenuFilters(selectedFilters)
    }

    private func clearCurrentDailyMenu() {
        currentDailyMenu = nil
        mealSections = []
        mealSectionRenderScheduler.clear()
    }
    
    @MainActor
    func loadFestivalDates() async {
        do {
            let dates = try await fetchFestivalDatesUseCase.execute()
            festivalDates = dates
            refreshFestivalSwitchState()
        } catch {
            print("Failed to load festival dates: \(error)")
        }
    }
    static func getOperatingHours(operatingHours: [String], dayType: Int, selectedPage: Int) -> String {
      
        guard operatingHours.count > dayType,
              dayType >= 0 else {
            return "정보 없음"
        }
        
        let dayOperatingHours = operatingHours[dayType].split(separator: "\n").map { String($0) }
        if dayOperatingHours.count == 3{
            guard dayOperatingHours.indices.contains(selectedPage) else {
                return "정보 없음"
            }
            return dayOperatingHours[selectedPage]
        }
        if dayOperatingHours.count == 2{
            if selectedPage == TypeSelection.breakfast.rawValue{
                return "정보 없음"
            }
            let index = selectedPage - 1
            guard dayOperatingHours.indices.contains(index) else {
                return "정보 없음"
            }
            return dayOperatingHours[index]
        }
        if dayOperatingHours.count == 1{
            return dayOperatingHours[0]
        }
        return "정보 없음"
        
    }
}

extension DateType {
    var operatingHourType: Int {
        switch self {
        case .weekdays:
            return 0
        case .saturday:
            return 1
        case .holiday:
            return 2
        }
    }
}

extension MenuViewModel: CLLocationManagerDelegate {
    
}

extension MenuViewModel {
    var pageName: String { selectedFilters.isFavorite ?? false ? PageName.favoritesList.rawValue : PageName.storeList.rawValue }
}
