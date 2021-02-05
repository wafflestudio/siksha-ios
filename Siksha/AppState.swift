//
//  AppState.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/02.
//

import Foundation
import SwiftyJSON
import Realm
import RealmSwift
import Combine

class AppState: ObservableObject {
    private let url = URL(string: "-")!
    private var cancellables = Set<AnyCancellable>()
    
    private let realm = try! Realm()
    
    // string value for page tab
    var dateFormatted = [String]()
    
    @Published var dailyMenus: [DailyMenu] = []
    
    @Published var failedToGetMenu: Bool = false
    
    @Published var saveToDB: Bool = false
    
    @Published var showSheet: Bool = false
    @Published var restaurantToShow: Restaurant? = nil
    @Published var mealToReview: Meal? = nil
    
    @Published var ratingEnabled: Bool = true
    
    var modalHeight: CGFloat {
        if restaurantToShow != nil {
            return 400
        } else if mealToReview != nil {
            return 320
        } else {
            return 0
        }
    }

    init(){
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_kr")
        formatter.dateFormat = "yyyy-MM-dd"
        
        let today = Date()
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today) ?? today
        
        let todayString = formatter.string(from: today)
        let tomorrowString = formatter.string(from: tomorrow)
        
        formatter.dateFormat = "MM. dd. E"
        dateFormatted.append(formatter.string(from: today))
        dateFormatted.append(formatter.string(from: tomorrow))
        
        $saveToDB
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                try! self.realm.write {
                    let allMenus = self.realm.objects(DailyMenu.self)
                    self.realm.delete(allMenus)
                    
                    self.dailyMenus.forEach { menu in
                        self.realm.add(menu)
                    }
                }
            }
            .store(in: &cancellables)
        
        $restaurantToShow
            .filter { $0 != nil }
            .sink { [weak self] restaurant in
                guard let self = self else { return }
                self.showSheet = true
            }
            .store(in: &cancellables)
        
        $mealToReview
            .filter { $0 != nil }
            .sink { [weak self] restaurant in
                guard let self = self else { return }
                self.showSheet = true
            }
            .store(in: &cancellables)
        
        $showSheet
            .filter { !$0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.restaurantToShow = nil
                self.mealToReview = nil
            }
            .store(in: &cancellables)
        
        if let todayMenu = realm.objects(DailyMenu.self).filter("date LIKE %@", todayString).first,
           let tomorrowMenu = realm.objects(DailyMenu.self).filter("date LIKE %@", tomorrowString).first {
            dailyMenus.append(todayMenu)
            dailyMenus.append(tomorrowMenu)
        } else {
//            getMenus()
            getMenuDebug()
        }
    }
    
    func getMenus() {
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure = completion {
                    self.failedToGetMenu = true
                }
            } receiveValue: { [weak self] (data, response) in
                guard let self = self else { return }
                guard let response = response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode,
                      let jsonArray = try? JSON(data: data).array else {
                    self.failedToGetMenu = true
                    return
                }
                self.dailyMenus.removeAll()
                jsonArray.forEach { json in
                    self.dailyMenus.append(DailyMenu(json))
                }
                self.saveToDB = true
            }
            .store(in: &cancellables)
    }
    
    // MARK: - only for debugging purpose
    
    func getMenuDebug(){
        var meals = [Meal]()
        for i in 0..<3 {
            let meal = Meal()
            meal.id = i
            meal.nameKr = "식단 \(i)"
            meal.price = 3000
            meal.reviewCnt = 1
            meal.score = Double(i) * 0.5
            meals.append(meal)
        }
        
        var restaurants = [Restaurant]()
        
        for i in 0..<3 {
            let restaurant = Restaurant()
            restaurant.id = i
            restaurant.nameKr = "식당 \(i)"
            if i != 2 {
                restaurant.menus.append(objectsIn: meals)
            }
            restaurant.addr = "301동 \(i)층"
            
            restaurants.append(restaurant)
        }
        
        var dailyMenus = [DailyMenu]()
        
        for i in 0..<2 {
            let menu = DailyMenu()
            menu.date = dateFormatted[i]
            menu.br.append(objectsIn: restaurants)
            menu.lu.append(objectsIn: restaurants)
            menu.dn.append(objectsIn: restaurants)
            
            dailyMenus.append(menu)
        }
        
        self.dailyMenus.append(contentsOf: dailyMenus)
    }
}
