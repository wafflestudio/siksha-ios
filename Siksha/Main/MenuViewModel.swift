//
//  MenuViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import Combine


public struct MenuFilters:Codable {
    var distance: Int? = nil               // Distance in meters (e.g., 400m); nil = all distances
    var priceRange: ClosedRange<Int>? = nil // Price range (e.g., 5000원 ~ 8000원); nil = all prices
    var isOpen: Bool? = nil                // Open status; true = open only, nil = open + closed
    var hasReview: Bool? = nil             // Review status; true = with reviews only, nil = review + no review
    var minimumRating: Float? = nil        // Minimum rating (e.g., 3.5); nil = all ratings
    var categories: [String]? = nil            // Category filter (e.g., 한식, 중식); nil = all categories
}

public class MenuViewModel: ObservableObject {
    
    let FESTIVAL_END: Date
    let MAX_PRICE = 15000
    private var cancellables = Set<AnyCancellable>()
    
    @Published var selectedFilters: MenuFilters = MenuFilters()
    
    private let repository = MenuRepository()
    private let formatter = DateFormatter()
    
    private var todayString: String {
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }
    
    @Published var showCalendar: Bool = false

    @Published var selectedDate: String
    @Published var nextDate: String = ""
    @Published var prevDate: String = ""
    
    @Published var selectedFormatted: String = ""

    @Published var selectedMenu: DailyMenu? = nil
    @Published var restaurantsLists: [[Restaurant]] = []
    @Published var noMenu = false
    
    @Published var getMenuStatus: MenuStatus = .idle
    
    @Published var showNetworkAlert: Bool = false
    
    @Published var selectedPage: Int = 0
    @Published var pageViewReload: Bool = false
    
    @Published var reloadOnAppear: Bool = true
    
    
    @Published var isFestivalAvailable: Bool
    @Published var isFestival: Bool = false
    
    public var priceLabel:String{
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        
        if let priceRange = selectedFilters.priceRange{
            let formattedLower = numberFormatter.string(from: NSNumber(value: priceRange.lowerBound))!
            let formattedUpper = numberFormatter.string(from: NSNumber(value: priceRange.upperBound))!
            if priceRange.upperBound == MAX_PRICE{
                return "\(formattedLower)원 ~ \(formattedUpper)원 이상"
            }
            else{
                return "\(formattedLower)원 ~ \(formattedUpper)원"
            }
        }
        return "가격"
    }
    public var distanceLabel:String{
        if let distance = selectedFilters.distance{
            return "\(distance)m 이내"
        }
        return "거리"
    }
    public var minRatingLabel:String{
        if let minimumRating = selectedFilters.minimumRating{
            return "평점 \(minimumRating) 이상"
        }
        return "최소 평점"
    }
    public var categoryLabel:String{
        if let categories = selectedFilters.categories{
            return categories.joined(separator: ",")
        }
        return "카테고리"
    }
    init() {
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "yyyy-MM-dd"
        FESTIVAL_END = Calendar(identifier: .gregorian).startOfDay(for: formatter.date(from: "2024-09-27")!)

        selectedDate = formatter.string(from: Date())
        isFestivalAvailable = Date() < FESTIVAL_END
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.hour], from: Date())
        if let hour = components.hour {
            if hour > 16 {
                selectedPage = 2
            } else if hour > 11 {
                selectedPage = 1
            }
        }
        $isFestivalAvailable.sink{ [weak self]
            available in
            if(!available){
                self?.isFestival = false
            }
        }.store(in: &cancellables)
        isFestival = isFestivalAvailable && UserDefaults.standard.bool(forKey: "isFestival")
        $isFestival.sink{
            isFestival in
            UserDefaults.standard.set(isFestival,forKey: "isFestival")
        }.store(in: &cancellables)
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
        
        $getMenuStatus
            .filter { $0 == .succeeded || $0 == .showCached }
            .combineLatest($selectedDate)
            .sink { [weak self] (_, date) in
                guard let self = self else { return }
                
                self.showCalendar = false
                self.selectedMenu = self.repository.getMenu(date: date)
                
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
        
        $selectedMenu
            .combineLatest($isFestival)
            .sink { [weak self] (menu,isFestival) in
                guard let self = self else { return }
                
                if let menu = menu {
                    let restOrder = (UserDefaults.standard.dictionary(forKey: "restaurantOrder") as? [String : Int]) ?? [String : Int]()
                    
                    let br = Array(menu.getRestaurants(.breakfast))
                        .filter{ restaurant in
                            restaurant.nameKr.contains("[축제]") == isFestival
                        }
                        .sorted { restOrder["\($0.id)"] ?? 0 < restOrder["\($1.id)"] ?? 0 }
                        
                    let lu = Array(menu.getRestaurants(.lunch))
                        .filter{ restaurant in
                            restaurant.nameKr.contains("[축제]") == isFestival
                        }
                        .sorted { restOrder["\($0.id)"] ?? 0 < restOrder["\($1.id)"] ?? 0 }
                    let dn = Array(menu.getRestaurants(.dinner))
                        .filter{ restaurant in
                            restaurant.nameKr.contains("[축제]") == isFestival
                        }
                        .sorted { restOrder["\($0.id)"] ?? 0 < restOrder["\($1.id)"] ?? 0 }
                    self.restaurantsLists = [br, lu, dn]
                    self.noMenu = false
                } else {
                    self.noMenu = true
                }
                self.pageViewReload = true
            }
            .store(in: &cancellables)
        self.selectedFilters = loadFilters() ?? MenuFilters()
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
    func loadFilters() -> MenuFilters?{
        if let savedFilters = UserDefaults.standard.object(forKey: "menuFilters") as? Data{
            let decoder = JSONDecoder()
            if let filters = try? decoder.decode(MenuFilters.self, from: savedFilters){
                return filters
            }
        }
        return nil
    }
    func saveFilters(){
        let encoder = JSONEncoder()
        if let filters = try? encoder.encode(selectedFilters){
            UserDefaults.standard.setValue(filters, forKey: "menuFilters")
        }
    }
}
