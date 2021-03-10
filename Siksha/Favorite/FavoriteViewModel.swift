//
//  FavoriteViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/06.
//

import Foundation
import Combine

public class FavoriteViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    private let todayString: String
    
    private let repository = MenuRepository()
    private let formatter = DateFormatter()

    @Published var selectedDate: String
    @Published var nextDate: String = ""
    @Published var prevDate: String = ""
    
    @Published var selectedFormatted: String = ""
    @Published var nextFormatted: String = ""
    @Published var prevFormatted: String = ""
    
    @Published var dailyMenus: [DailyMenu]
    @Published var selectedMenu: DailyMenu? = nil
    @Published var restaurantsLists: [[Restaurant]] = []
    @Published var noMenu = false
    
    @Published var getMenuStatus: NetworkStatus = .idle
    
    @Published var showNetworkAlert: Bool = false
    
    @Published var selectedPage: Int = 0
    
    @Published var noFavorites: Bool = false
    
    init() {
        dailyMenus = repository.dailyMenus
        
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "yyyy-MM-dd"
        
        selectedDate = formatter.string(from: Date())
        todayString = formatter.string(from: Date())
        
        $selectedDate
            .sink { [weak self] dateString in
                guard let self = self else { return }
                
                self.formatter.dateFormat = "yyyy-MM-dd"
                let selected = self.formatter.date(from: dateString) ?? Date()
                
                let next = selected.addingTimeInterval(86400)
                let prev = selected.addingTimeInterval(-86400)
                
                self.formatter.dateFormat = "yyyy-MM-dd"
                self.nextDate = self.formatter.string(from: next)
                self.prevDate = self.formatter.string(from: prev)
                
                self.formatter.dateFormat = "MM. dd. E"
                self.selectedFormatted = self.formatter.string(from: selected)
                self.nextFormatted = self.formatter.string(from: next)
                self.prevFormatted = self.formatter.string(from: prev)
                
                self.getMenu(date: dateString)
            }
            .store(in: &cancellables)
        
        $getMenuStatus
            .combineLatest($dailyMenus)
            .sink { [weak self] (_, menus) in
                guard let self = self else { return }
                
                self.selectedMenu = menus.first { $0.date == self.selectedDate }
                if self.selectedDate == self.todayString {
                    UserDefaults.standard.set(true, forKey: "canSubmitReview")
                } else {
                    UserDefaults.standard.set(false, forKey: "canSubmitReview")
                }
            }
            .store(in: &cancellables)
        
        $getMenuStatus
            .filter { $0 == .failed }
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                self.showNetworkAlert = true
            }
            .store(in: &cancellables)
        
        $selectedMenu
            .sink { [weak self] menu in
                guard let self = self else { return }
                
                if let menu = menu {
                    let restOrder = (UserDefaults.standard.dictionary(forKey: "favRestaurantOrder") as? [String : Int]) ?? [String : Int]()
                    
                    let br = Array(menu.getRestaurants(.breakfast))
                        .filter { UserDefaults.standard.bool(forKey: "fav\($0.id)") }
                        .sorted { restOrder["\($0.id)"] ?? 0 < restOrder["\($1.id)"] ?? 0 }
                    let lu = Array(menu.getRestaurants(.lunch))
                        .filter { UserDefaults.standard.bool(forKey: "fav\($0.id)") }
                        .sorted { restOrder["\($0.id)"] ?? 0 < restOrder["\($1.id)"] ?? 0 }
                    let dn = Array(menu.getRestaurants(.dinner))
                        .filter { UserDefaults.standard.bool(forKey: "fav\($0.id)") }
                        .sorted { restOrder["\($0.id)"] ?? 0 < restOrder["\($1.id)"] ?? 0 }
                    self.restaurantsLists = [br, lu, dn]
                    
                    if br.count == 0, lu.count == 0, dn.count == 0 {
                        self.noFavorites = true
                    } else {
                        self.noFavorites = false
                    }
                    
                    self.noMenu = false
                } else {
                    self.noMenu = true
                }
            }
            .store(in: &cancellables)
    }
    
    func getMenu(date: String) {
        guard self.getMenuStatus != .loading else {
            return
        }
        
        self.getMenuStatus = .loading
        repository.getMenuPublisher(startDate: date, endDate: date)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure = completion {
                    self.getMenuStatus = .failed
                }
            } receiveValue: { [weak self] (data, response) in
                guard let self = self else { return }
                guard let response = response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode else {
                    self.getMenuStatus = .failed
                    return
                }
                self.getMenuStatus = .succeeded
                self.dailyMenus = self.repository.dailyMenus
            }
            .store(in: &cancellables)
    }
}
