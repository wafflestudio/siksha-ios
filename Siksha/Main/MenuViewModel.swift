//
//  MenuViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import Combine
import Realm
import RealmSwift
import CoreLocation
import SwiftyJSON

final class MenuViewModel: NSObject, ObservableObject {
    let isFavoriteTab: Bool
    
    private let FESTIVAL_END: Date
    private let MAX_PRICE = 10000
    private var cancellables = Set<AnyCancellable>()
    
    private let repository = MenuRepository()
    private let formatter = DateFormatter()
    private let locationManager = CLLocationManager()
    
    @Published var showCalendar: Bool = false
    
    @Published var selectedDate: String
    @Published var nextDate: String = ""
    @Published var prevDate: String = ""
    
    @Published var selectedFormatted: String = ""
    
    @Published var selectedMenu: DailyMenu? = nil
    @Published var selectedFilters: MenuFilters = MenuFilters()
    @Published var restaurantsLists: [[Restaurant]] = []
    
    @Published var getMenuStatus: MenuStatus = .idle
    
    @Published var showNetworkAlert: Bool = false
    @Published var showDistanceAlert: Bool = false
    
    @Published var selectedPage: Int = 0
    @Published var pageViewReload: Bool = false
    
    @Published var reloadOnAppear: Bool = true
    
    @Published var isFestivalAvailable: Bool
    @Published var isFestival: Bool = false
    
    @Published var noFavorites: Bool = false
    
    private var todayString: String {
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
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
    
    init(isFavoriteTab: Bool = false) {
        self.isFavoriteTab = isFavoriteTab
        
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "yyyy-MM-dd"
        
        FESTIVAL_END = Calendar(identifier: .gregorian).startOfDay(for: formatter.date(from: "2024-09-27")!)
        
        selectedDate = formatter.string(from: Date())
        
        isFestivalAvailable = Date() < FESTIVAL_END
        
        super.init()
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
        subscribe()
    }
    
    private func subscribe() {
        subscribeToIsFestivalAvailable()
        subscribeToIsFestival()
        subscribeToSelectedDate()
        subscribeToGetMenuStatus()
        subscribeToSelectedMenu()
    }
    
    private func subscribeToIsFestivalAvailable() {
        $isFestivalAvailable.sink{ [weak self]
            available in
            if (!available) {
                self?.isFestival = false
            }
        }.store(in: &cancellables)
    }
    
    private func subscribeToIsFestival() {
        $isFestival.sink{
            isFestival in
            UserDefaults.standard.set(isFestival,forKey: "isFestival")
        }.store(in: &cancellables)
    }
    
    private func subscribeToSelectedDate() {
        $selectedDate
            .removeDuplicates()
            .sink { [weak self] dateString in
                guard let self = self else { return }
                isFestivalAvailable = Date() < FESTIVAL_END
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
            }
            .store(in: &cancellables)
    }
    
    private func subscribeToGetMenuStatus() {
        $getMenuStatus
            .filter { $0 == .succeeded || $0 == .needRerender || $0 == .showCached }
            .combineLatest($selectedFilters)
            .sink { [weak self] (_, filters) in
                guard let self = self else { return }
                
                self.showCalendar = false
                
                let managedMenu = self.repository.getMenu(date: selectedDate)
                if managedMenu == nil {
                    self.selectedMenu = nil
                } else {
                    self.selectedMenu = filterMenus(DailyMenu(value: managedMenu), filter: filters)
                }
                
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
        $selectedMenu
            .combineLatest($isFestival)
            .sink { [weak self] (menu,isFestival) in
                guard let self = self else { return }
                
                if let menu = menu {
                    let restOrder = (UserDefaults.standard.dictionary(forKey: isFavoriteTab ? "favRestaurantOrder" : "restaurantOrder") as? [String : Int]) ?? [String : Int]()
                    
                    let br = Array(menu.getRestaurants(.breakfast))
                        .filter {
                            if self.isFavoriteTab {
                                return UserDefaults.standard.bool(forKey: "fav\($0.id)")
                            } else {
                                return true
                            }
                        }
                        .filter{ restaurant in
                            restaurant.nameKr.contains("[축제]") == isFestival
                        }
                        .sorted { restOrder["\($0.id)"] ?? 0 < restOrder["\($1.id)"] ?? 0 }
                    
                    let lu = Array(menu.getRestaurants(.lunch))
                        .filter {
                            print("filter: \(self.isFavoriteTab)")
                            if self.isFavoriteTab {
                                print($0.nameKr)
                                print(UserDefaults.standard.bool(forKey: "fav\($0.id)"))
                                return UserDefaults.standard.bool(forKey: "fav\($0.id)")
                            } else {
                                return true
                            }
                        }
                        .filter{ restaurant in
                            restaurant.nameKr.contains("[축제]") == isFestival
                        }
                        .sorted { restOrder["\($0.id)"] ?? 0 < restOrder["\($1.id)"] ?? 0 }
                    let dn = Array(menu.getRestaurants(.dinner))
                        .filter {
                            if self.isFavoriteTab {
                                return UserDefaults.standard.bool(forKey: "fav\($0.id)")
                            } else {
                                return true
                            }
                        }
                        .filter{ restaurant in
                            restaurant.nameKr.contains("[축제]") == isFestival
                        }
                        .sorted { restOrder["\($0.id)"] ?? 0 < restOrder["\($1.id)"] ?? 0 }
                    self.restaurantsLists = [br, lu, dn]
                    
                    if isFavoriteTab && br.count == 0 && lu.count == 0 && dn.count == 0 {
                        self.checkNoFavorites()
                    } else {
                        self.noFavorites = false
                    }
                }
                self.pageViewReload = true
            }
            .store(in: &cancellables)
    }
    
    func checkNoFavorites() {
        Networking.shared.getRestaurants()
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                guard let data = result.data,
                      let restJSON = try? JSON(data: data)["result"].array else {
                    self.noFavorites = false
                    return
                }
                var hasFavorite = false
                restJSON.forEach { json in
                    let id = json["id"].intValue
                    if UserDefaults.standard.bool(forKey: "fav\(id)") {
                        hasFavorite = true
                        return
                    }
                }
                self.noFavorites = !hasFavorite
            }
            .store(in: &cancellables)
    }
    
    private func filterMenus(_ menus: DailyMenu, filter: MenuFilters) -> DailyMenu {
        var menus = menus
        menus.br = filterRestaurants(restaurants: menus.br, filter: filter)
        menus.lu = filterRestaurants(restaurants: menus.lu, filter: filter)
        menus.dn = filterRestaurants(restaurants: menus.dn, filter: filter)
        return menus
    }
    
    private func filterRestaurants(restaurants: List<Restaurant>, filter: MenuFilters) -> List<Restaurant> {
        let filteredArray: [Restaurant] = Array(restaurants).compactMap { (restaurant: Restaurant) -> Restaurant? in
            // 영업 중인지 체크 (휴일 등은 추후 처리)
            if filter.isOpen == true && !isRestaurantOpen(restaurant) {
                return nil
            }
            
            // 거리 필터 적용
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
                            // 레스토랑 위치 정보가 없으면 거리 필터 적용시 해당 레스토랑 제거
                            return nil
                        }
                    } else {
                        selectedFilters.distance = nil
                        DispatchQueue.main.async { self.showDistanceAlert = true }
                    }
                }
            }
            
            // 메뉴 필터 적용
            let filteredMenus = filterRestaurantMenus(restaurant.menus, filter: filter)
            if filteredMenus.isEmpty { return nil }
            
            // 새 메뉴 List에 필터링된 메뉴들을 추가
            let newMenus = List<Meal>()
            for menu in filteredMenus {
                newMenus.append(menu)
            }
            restaurant.menus = newMenus
            
            return restaurant
        }
        
        let newList = List<Restaurant>()
        filteredArray.forEach { newList.append($0) }
        return newList
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
    
    func getMenu(date: String) {
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
    
    func saveFilters() {
        let encoder = JSONEncoder()
        if let filters = try? encoder.encode(selectedFilters) {
            UserDefaults.standard.setValue(filters, forKey: "menuFilters")
        }
    }
}

extension MenuViewModel: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
    }
}
