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
    private let festivalRepository: FestivalRepositoryProtocol
    private let fetchRemoteConfigUseCase: FetchRemoteConfigUseCase
    private let observeRemoteConfigUseCase: ObserveRemoteConfigUseCase
    private let fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase
    private let updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase
    private let mealSectionDisplayModelBuilder: MealSectionDisplayModelBuilder
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
    
    @Published var selectedMenu: DailyMenuModel? = nil
    @Published var selectedFilters: MenuFilters = MenuFilters()
    @Published var mealSections: [MealSectionDisplayModel] = []
    
    @Published var getMenuStatus: MenuStatus = .idle
    
    @Published var showNetworkAlert: Bool = false
    @Published var showDistanceAlert: Bool = false
    
    @Published var selectedPage: Int = 0
    
    @Published var reloadOnAppear: Bool = true
    
    @Published var isFestivalAvailable: Bool
    @Published var isFestival: Bool = false
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
    
    init(
        analytics: AnalyticsService = MixpanelAnalytics(),
        fetchDailyMenuUseCase: FetchDailyMenuUseCase = DefaultFetchDailyMenuUseCase(
            repository: MenuRepositoryImpl()
        ),
        festivalRepository: FestivalRepositoryProtocol = FestivalRepositoryImpl(),
        fetchRemoteConfigUseCase: FetchRemoteConfigUseCase = DefaultFetchRemoteConfigUseCase(
            repository: RemoteConfigRepositoryImpl()
        ),
        observeRemoteConfigUseCase: ObserveRemoteConfigUseCase = DefaultObserveRemoteConfigUseCase(
            repository: RemoteConfigRepositoryImpl()
        ),
        fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase = DefaultFetchPersonalRestaurantsUseCase(
            repository: RestaurantRepositoryImpl()
        ),
        updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase = DefaultUpdateRestaurantPreferenceUseCase(
            repository: RestaurantRepositoryImpl()
        ),
        mealSectionDisplayModelBuilder: MealSectionDisplayModelBuilder = MealSectionDisplayModelBuilder()
    ) {
        self.analytics = analytics
        self.fetchDailyMenuUseCase = fetchDailyMenuUseCase
        self.festivalRepository = festivalRepository
        self.fetchRemoteConfigUseCase = fetchRemoteConfigUseCase
        self.observeRemoteConfigUseCase = observeRemoteConfigUseCase
        self.fetchPersonalRestaurantsUseCase = fetchPersonalRestaurantsUseCase
        self.updateRestaurantPreferenceUseCase = updateRestaurantPreferenceUseCase
        self.mealSectionDisplayModelBuilder = mealSectionDisplayModelBuilder
        
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "yyyy-MM-dd"
        selectedDate = formatter.string(from: Date())
        
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
        dateRange = CurrentValueSubject((formatter.string(from: today), formatter.string(from: tomorrow)))
        
        isFestivalAvailable = UserDefaults.standard.bool(forKey: "isFestivalAvailable")
        isFestivalAppIconEnabled = UserDefaults.standard.bool(forKey: "isFestivalAppIconEnabled")
        
        super.init()

        remoteConfigFetchTask = Task { [weak self] in
            await self?.loadRemoteConfig()
        }
        startObservingRemoteConfigUpdates()
        
        isFestival = isFestivalAvailable && UserDefaults.standard.bool(forKey: "isFestival")
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
        UserDefaults.standard.set(config.festivalFeatureEnabled, forKey: "isFestivalAvailable")
        isFestivalAppIconEnabled = config.festivalAppIconEnabled
        refreshFestivalSwitchState()
    }
    
    private func subscribe() {
        subscribeToIsFestivalAppIconEnabled()
        subscribeToIsFestival()
        subscribeToSelectedDate()
        subscribeToSelectedMenu()
    }
    
    private func subscribeToIsFestivalAppIconEnabled() {
        $isFestivalAppIconEnabled
            .sink { [weak self] enabled in
                guard let self = self else { return }
                UserDefaults.standard.set(enabled, forKey: "isFestivalAppIconEnabled")
                
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
    
    private func subscribeToIsFestival() {
        $isFestival.sink {
            isFestival in
            UserDefaults.standard.set(isFestival,forKey: "isFestival")
        }.store(in: &cancellables)
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
    
    private func subscribeToSelectedMenu() {
        $isFestival
            .removeDuplicates()
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.rebuildMealSections(filters: self.selectedFilters)
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
            applyCurrentMenu(filters: selectedFilters)
        } catch {
            print("Failed to load personal restaurants: \(error)")

            if personalRestaurantById.isEmpty {
                shouldUseDefaultRestaurantPreference = true
                applyCurrentMenu(filters: selectedFilters)
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
    
    private func applyCurrentMenu(filters: MenuFilters) {
        guard selectedMenu != nil else {
            selectedMenu = nil
            mealSections = []
            return
        }
        
        rebuildMealSections(filters: filters)
    }
    
    private func refreshFestivalSwitchState(selectedDate selected: Date? = nil) {
        let selected = selected ?? currentSelectedDate()
        showFestivalSwitch = isFestivalAvailable && festivalDates.contains(selected)
        if !showFestivalSwitch {
            isFestival = false
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
            rebuildMealSections(filters: selectedFilters)
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
    
    private func rebuildMealSections(filters: MenuFilters) {
        guard let selectedMenu else {
            mealSections = []
            return
        }

        let resolvedFilters = resolveDistanceFilterIfNeeded(filters)
        let noMenuHide = !UserDefaults.standard.bool(forKey: "notNoMenuHide")
        mealSections = mealSectionDisplayModelBuilder.build(
            input: MealSectionDisplayModelBuilder.Input(
                menu: selectedMenu,
                filters: resolvedFilters,
                personalRestaurantById: personalRestaurantById,
                personalRestaurantOrder: personalRestaurantOrder,
                shouldUseDefaultRestaurantPreference: shouldUseDefaultRestaurantPreference,
                noMenuHide: noMenuHide,
                selectedDate: selectedDate,
                currentLocation: locationManager.location
            )
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

    private func resolveDistanceFilterIfNeeded(_ filters: MenuFilters) -> MenuFilters {
        guard filters.distance != nil else {
            return filters
        }

        checkLocationAuthorization()
        guard locationManager.authorizationStatus == .authorizedAlways ||
              locationManager.authorizationStatus == .authorizedWhenInUse,
              locationManager.location != nil else {
            var resolvedFilters = filters
            resolvedFilters.distance = nil
            selectedFilters = resolvedFilters
            saveFilters()
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
                selectedMenu = menu
                rebuildMealSections(filters: selectedFilters)
                getMenuStatus = .idle
            case .empty:
                selectedMenu = nil
                mealSections = []
                getMenuStatus = .idle
            case .cached(let menu):
                selectedMenu = menu
                rebuildMealSections(filters: selectedFilters)
                showNetworkAlert = true
                getMenuStatus = .idle
            case .failed:
                selectedMenu = nil
                mealSections = []
                showNetworkAlert = true
                getMenuStatus = .failed
            }
            
            UserDefaults.standard.set(selectedDate == todayString, forKey: "canSubmitReview")
        }
    }
    
    func loadFilters() {
        if let savedFilters = UserDefaults.standard.object(forKey: "menuFilters") as? Data {
            let decoder = JSONDecoder()
            if let filters = try? decoder.decode(MenuFilters.self, from: savedFilters) {
                self.selectedFilters = filters
                return
            }
        }
        self.selectedFilters = MenuFilters()
    }
    
    func updateFilters(_ update: (inout MenuFilters) -> Void) {
        var filters = selectedFilters
        update(&filters)
        setFilters(filters)
    }
    
    func setFilters(_ filters: MenuFilters) {
        selectedFilters = filters
        saveFilters()
        applyCurrentMenu(filters: filters)
    }
    
    private func saveFilters() {
        let encoder = JSONEncoder()
        if let filters = try? encoder.encode(selectedFilters) {
            UserDefaults.standard.setValue(filters, forKey: "menuFilters")
        }
    }
    
    @MainActor
    func loadFestivalDates() async {
        do {
            let dates = try await festivalRepository.fetchFestivalDates()
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
