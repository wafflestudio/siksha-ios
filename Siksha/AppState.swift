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
    private let url = URL(string: "https://siksha.kr:8000/api/v1/snu/menus/")!
    private var cancellables = Set<AnyCancellable>()
    
    private let realm = try! Realm()
    
    // string value for page tab
    var dateFormatted = [String]()
    
    @Published var dailyMenus: [DailyMenu] = []
    
    @Published var getResult: Result = .idle
    
    @Published var restaurants: [Restaurant] = []
    
    @Published var restaurantOrder = [Int : Int]()
    
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
        
        $getResult
            .filter { $0 == .succeeded }
            .sink { [weak self] _ in
                guard let self = self else { return }
                
                // Save To DB
                try! self.realm.write {
                    let allMenus = self.realm.objects(DailyMenu.self)
                    self.realm.delete(allMenus)
                    
                    self.dailyMenus.forEach { menu in
                        self.realm.add(menu)
                    }
                }
                
                self.getResult = .idle
                
            }
            .store(in: &cancellables)

        
        if let todayMenu = realm.objects(DailyMenu.self).filter("date LIKE %@", todayString).first,
           let tomorrowMenu = realm.objects(DailyMenu.self).filter("date LIKE %@", tomorrowString).first {
            dailyMenus.append(todayMenu)
            dailyMenus.append(tomorrowMenu)
        } else {
            getMenus()
        }
    }
    
    func getMenus() {
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure = completion {
                    self.getResult = .failed
                }
            } receiveValue: { [weak self] (data, response) in
                guard let self = self else { return }
                guard let response = response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode,
                      let jsonArray = try? JSON(data: data).array else {
                    self.getResult = .failed
                    return
                }
                self.dailyMenus.removeAll()
                jsonArray.forEach { json in
                    self.dailyMenus.append(DailyMenu(json))
                }
                self.getResult = .succeeded
            }
            .store(in: &cancellables)
    }
    
    func getRestaurants() {
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure:
                    self.restaurants = []
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (data, response) in
                guard let self = self else { return }
                guard let response = response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode,
                      let jsonArray = try? JSON(data: data).array else {
                    self.getResult = .failed
                    return
                }
                self.restaurants.removeAll()
                jsonArray.forEach { json in
                    self.restaurants.append(Restaurant(json))
                }
                
                self.getResult = .succeeded
            }
            .store(in: &cancellables)
    }
    
    
    // repetitive code?
    func getRestaurantOrder() -> [Int: Int] {
        URLSession.shared.dataTaskPublisher(for: url)
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
            .sink { [weak self] completion in
                guard let self = self else { return }
                switch completion {
                case .failure:
                    self.restaurantOrder = [Int: Int]()
                case .finished:
                    break
                }
            } receiveValue: { [weak self] (data, response) in
                guard let self = self else { return }
                guard let response = response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode,
                      let _ = try? JSON(data: data).array else {
                    self.getResult = .failed
                    return
                }
                // If getRestaurants not failed?
                self.restaurantOrder.removeAll()
                for (i, Restaurant) in self.restaurants.enumerated() {
                    self.restaurantOrder[Restaurant.id] = i
                }
                self.getResult = .succeeded
            }
            .store(in: &cancellables)
        return self.restaurantOrder
    }
    
}


