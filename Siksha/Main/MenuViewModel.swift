//
//  MenuViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import Combine

public class MenuViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    private let repository = MenuRepository()
    private let formatter = DateFormatter()
    
    private var todayString: String {
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    @Published var selectedDate: String
    @Published var nextDate: String = ""
    @Published var prevDate: String = ""
    
    @Published var selectedFormatted: String = ""
    @Published var nextFormatted: String = ""
    @Published var prevFormatted: String = ""

    @Published var selectedMenu: DailyMenu? = nil
    @Published var restaurantsLists: [[Restaurant]] = []
    @Published var noMenu = false
    
    @Published var getMenuStatus: MenuStatus = .idle
    
    @Published var showNetworkAlert: Bool = false
    
    @Published var selectedPage: Int = 0
    @Published var pageViewReload: Bool = false
    
    @Published var reloadOnAppear: Bool = true
    
    init() {
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "yyyy-MM-dd"
        
        selectedDate = formatter.string(from: Date())
        
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.hour], from: Date())
        if let hour = components.hour {
            if hour > 16 {
                selectedPage = 2
            } else if hour > 11 {
                selectedPage = 1
            }
        }
        
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
                
//                self.formatter.dateFormat = "MM. dd. E"
                self.formatter.dateFormat = "yyyy-MM-dd (E)"
                self.selectedFormatted = self.formatter.string(from: selected)
                self.nextFormatted = self.formatter.string(from: next)
                self.prevFormatted = self.formatter.string(from: prev)
                
                self.pageViewReload = true
                self.getMenu(date: dateString)
            }
            .store(in: &cancellables)
        
        $getMenuStatus
            .filter { $0 == .succeeded || $0 == .showCached }
            .combineLatest($selectedDate)
            .sink { [weak self] (_, date) in
                guard let self = self else { return }

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
            .sink { [weak self] menu in
                guard let self = self else { return }
                
                if let menu = menu {
                    let restOrder = (UserDefaults.standard.dictionary(forKey: "restaurantOrder") as? [String : Int]) ?? [String : Int]()
                    
                    let br = Array(menu.getRestaurants(.breakfast))
                        .sorted { restOrder["\($0.id)"] ?? 0 < restOrder["\($1.id)"] ?? 0 }
                    let lu = Array(menu.getRestaurants(.lunch))
                        .sorted { restOrder["\($0.id)"] ?? 0 < restOrder["\($1.id)"] ?? 0 }
                    let dn = Array(menu.getRestaurants(.dinner))
                        .sorted { restOrder["\($0.id)"] ?? 0 < restOrder["\($1.id)"] ?? 0 }
                    self.restaurantsLists = [br, lu, dn]
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
        
        repository.fetchMenu(date: date)
            .receive(on: RunLoop.main)
            .assign(to: \.getMenuStatus, on: self)
            .store(in: &cancellables)
    }
}
