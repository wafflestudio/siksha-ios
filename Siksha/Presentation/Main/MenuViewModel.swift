//
//  MenuViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import UIKit
import Combine
import RealmSwift
import CoreLocation
import SwiftyJSON

struct RestaurantMenusDisplayModel: Identifiable {
    let id: String
    let restaurantId: Int
    let restaurant: Restaurant
    let menus: [Meal]
    let isFavorite: Bool
}

struct MealSectionDisplayModel: Identifiable {
    let id: Int
    let type: TypeSelection
    let restaurantMenus: [RestaurantMenusDisplayModel]
}

final class MenuViewModel: NSObject, ObservableObject {
    let analytics: AnalyticsService

    private var festivalDates: [Date] = []
    
    private let MAX_PRICE = 10000
    private var cancellables = Set<AnyCancellable>()
    
    private let repository = MenuRepository()
    private let festivalRepository: FestivalRepositoryProtocol
    private let fetchRemoteConfigUseCase: FetchRemoteConfigUseCase
    private let observeRemoteConfigUseCase: ObserveRemoteConfigUseCase
    private let fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase
    private let updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase
    private let formatter = DateFormatter()
    private let locationManager = CLLocationManager()
    private var remoteConfigFetchTask: Task<Void, Never>?
    private var remoteConfigUpdatesTask: Task<Void, Never>?
    private var personalRestaurantById: [Int: PersonalRestaurantModel] = [:]
    private var personalRestaurantOrder: [Int: Int] = [:]
    private var updatingLikeRestaurantIds = Set<Int>()
    private var isLoadingPersonalRestaurants = false
    
    @Published var showCalendar: Bool = false
    @Published var showFestivalSwitch: Bool = false
    
    @Published var selectedDate: String
    @Published var nextDate: String = ""
    @Published var prevDate: String = ""
    
    @Published var selectedFormatted: String = ""
    
    @Published var selectedMenu: DailyMenu? = nil
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
        )
    ) {
        self.analytics = analytics
        self.festivalRepository = festivalRepository
        self.fetchRemoteConfigUseCase = fetchRemoteConfigUseCase
        self.observeRemoteConfigUseCase = observeRemoteConfigUseCase
        self.fetchPersonalRestaurantsUseCase = fetchPersonalRestaurantsUseCase
        self.updateRestaurantPreferenceUseCase = updateRestaurantPreferenceUseCase
        
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
        subscribeToGetMenuStatus()
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
    
    private func subscribeToGetMenuStatus() {
        $getMenuStatus
            .filter { $0 == .succeeded || $0 == .needRerender || $0 == .showCached }
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.showCalendar = false
                self.applyCurrentMenu(filters: self.selectedFilters)
                
                if self.selectedDate == self.todayString {
                    UserDefaults.standard.set(true, forKey: "canSubmitReview")
                } else {
                    UserDefaults.standard.set(false, forKey: "canSubmitReview")
                }
                
                self.getMenuStatus = .idle
            }
            .store(in: &cancellables)
        
        $getMenuStatus
            .filter { $0 == .showCached }
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.showNetworkAlert = true
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
            updatePersonalRestaurants(restaurants)
            applyCurrentMenu(filters: selectedFilters)
        } catch {
            print("Failed to load personal restaurants: \(error)")
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
    }
    
    private func applyCurrentMenu(filters: MenuFilters) {
        guard let managedMenu = repository.getMenu(date: selectedDate) else {
            selectedMenu = nil
            mealSections = []
            return
        }
        
        selectedMenu = DailyMenu(value: managedMenu)
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
        
        mealSections = [
            MealSectionDisplayModel(
                id: TypeSelection.breakfast.rawValue,
                type: .breakfast,
                restaurantMenus: makeRestaurantMenusDisplayModels(
                    type: .breakfast,
                    restaurants: selectedMenu.br,
                    filter: filters
                )
            ),
            MealSectionDisplayModel(
                id: TypeSelection.lunch.rawValue,
                type: .lunch,
                restaurantMenus: makeRestaurantMenusDisplayModels(
                    type: .lunch,
                    restaurants: selectedMenu.lu,
                    filter: filters
                )
            ),
            MealSectionDisplayModel(
                id: TypeSelection.dinner.rawValue,
                type: .dinner,
                restaurantMenus: makeRestaurantMenusDisplayModels(
                    type: .dinner,
                    restaurants: selectedMenu.dn,
                    filter: filters
                )
            )
        ]
    }
    
    private func makeRestaurantMenusDisplayModels(
        type: TypeSelection,
        restaurants: List<Restaurant>,
        filter: MenuFilters
    ) -> [RestaurantMenusDisplayModel] {
        Array(restaurants).compactMap { (restaurant: Restaurant) -> RestaurantMenusDisplayModel? in
            guard let personalRestaurant = personalRestaurantById[restaurant.id],
                  personalRestaurant.visible else {
                return nil
            }
            
            if filter.isOpen == true && !isRestaurantOpen(restaurant) {
                return nil
            }
            
            if filter.isFavorite == true && !personalRestaurant.liked {
                return nil
            }
            
            if let distance = filter.distance {
                checkLocationAuthorization()
                
                if locationManager.authorizationStatus != .authorizedAlways && locationManager.authorizationStatus != .authorizedWhenInUse {
                    selectedFilters.distance = nil // 위치 이용 불가 시 distance filter off
                    DispatchQueue.main.async { self.showDistanceAlert = true }
                } else {
                    if let currentLocation = locationManager.location {
                        if let restaurantLocation = restaurant.location {
                            if currentLocation.distance(from: restaurantLocation) > Double(distance) {
                                return nil
                            }
                        } else {
                            return nil
                        }
                    } else {
                        selectedFilters.distance = nil
                        DispatchQueue.main.async { self.showDistanceAlert = true }
                    }
                }
            }
            
            let filteredMenus = filterRestaurantMenus(restaurant.menus, filter: filter)
            
            let noMenuHide = !UserDefaults.standard.bool(forKey: "notNoMenuHide") // 메뉴가 없으면 레스토랑 hide
            if noMenuHide && filteredMenus.isEmpty { return nil }
            
            return RestaurantMenusDisplayModel(
                id: "\(type.rawValue)-\(restaurant.id)",
                restaurantId: restaurant.id,
                restaurant: restaurant,
                menus: filteredMenus,
                isFavorite: personalRestaurant.liked
            )
        }
        .sorted { restaurantSortIndex($0.restaurant) < restaurantSortIndex($1.restaurant) }
    }
    
    private func restaurantSortIndex(_ restaurant: Restaurant) -> Int {
        personalRestaurantOrder[restaurant.id] ?? Int.max
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
        }
    }
    
    
    private func filterRestaurantMenus(_ menus: List<Meal>, filter: MenuFilters) -> [Meal] {
        return menus.filter { menu in
            
            var meetsPrice = true
            if let priceRange = filter.priceRange {
                let lower = priceRange.lowerBound
                let upper = priceRange.upperBound
                
                if upper < MAX_PRICE {
                    meetsPrice = priceRange.contains(menu.price)
                } else {
                    meetsPrice = menu.price >= lower
                }
            }
            
            var meetsReview = true
            if let hasReview = filter.hasReview,
               hasReview == true {
                meetsReview = menu.reviewCnt > 0
            }
            
            var meetsRate = true
            if let minimumRating = filter.minimumRating {
                meetsRate = menu.score >= Double(minimumRating)
            }
            
            var meetsCategories = true
            if let categories = filter.categories {
                // TODO: 추후 카테고리 추가시 구현
            }
            
            return meetsPrice && meetsReview && meetsRate && meetsCategories
        }
    }
    
    private func isRestaurantOpen(_ restaurant: Restaurant) -> Bool {
        var koreanCalendar = Calendar(identifier: .gregorian)
        koreanCalendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
        
        self.formatter.dateFormat = "yyyy-MM-dd"
        let selected = self.formatter.date(from: selectedDate) ?? Date()
        let weekday = koreanCalendar.component(.weekday, from: selected)
        
        let dayIndex: Int
        if weekday == 7 {
            dayIndex = 1  // 토요일
        } else if weekday == 1 {
            dayIndex = 2  // 일요일 (휴일로 처리)
        } else {
            dayIndex = 0  // 평일
        }
        
        guard restaurant.operatingHours.count > dayIndex else { return false }
        let hoursString = restaurant.operatingHours[dayIndex]
        guard !hoursString.isEmpty else { return false }
        
        let intervals = hoursString.components(separatedBy: "\n")
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        dateFormatter.dateFormat = "HH:mm"
        
        let now = Date().addingTimeInterval(0)
        let nowTimeStr = dateFormatter.string(from: now)
        
        var isRestaurantOpen = false
        
        for interval in intervals {
            let times = interval.components(separatedBy: " - ")
            if times.count == 2 {
                let startTime = times[0]
                let endTime = times[1]
                
                if nowTimeStr >= startTime && nowTimeStr <= endTime {
                    isRestaurantOpen = true
                    break
                }
                
                // 자정 넘기는 경우
                if startTime > endTime && nowTimeStr <= endTime {
                    isRestaurantOpen = true
                    break
                }
            }
        }
        return isRestaurantOpen
    }
    
    private func getMenu(date: String) {
        guard self.getMenuStatus != .loading else {
            return
        }
        
        self.getMenuStatus = .loading
        
        repository.fetchMenu(date: date)
            .receive(on: RunLoop.main)
            .assign(to: \.getMenuStatus, on: self)
            .store(in: &cancellables)
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
    static func getOperatingHours(restaurant:Restaurant,dayType:Int,selectedPage:Int)->String{
      
        let operatingHours = restaurant.operatingHours[dayType].split(separator: "\n").map { String($0) }
        if operatingHours.count == 3{
            return operatingHours[selectedPage]
        }
        if operatingHours.count == 2{
            if selectedPage == TypeSelection.breakfast.rawValue{
                return "정보 없음"
            }
            return operatingHours[selectedPage-1]
        }
        if operatingHours.count == 1{
            return operatingHours[0]
        }
        return "정보 없음"
        
    }
}

extension MenuViewModel: CLLocationManagerDelegate {
    
}

extension MenuViewModel {
    var pageName: String { selectedFilters.isFavorite ?? false ? PageName.favoritesList.rawValue : PageName.storeList.rawValue }
}
