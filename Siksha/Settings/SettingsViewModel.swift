//
//  SettingsViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import Combine
import SwiftyJSON

class SettingsViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var noMenuHide = false
    @Published var restaurantIds = [Int]()
    @Published var favRestaurantIds = [Int]()
    @Published var networkStatus: Result = .idle
    
    var restaurantOrder: [String : Int]
    var favRestaurantOrder: [String : Int]
    
    init() {
        noMenuHide = UserDefaults.standard.bool(forKey: "noMenuHide")
        
        restaurantOrder = UserDefaults.standard.dictionary(forKey: "restaurantOrder") as? [String : Int] ?? [String : Int]()
        favRestaurantOrder = UserDefaults.standard.dictionary(forKey: "favRestaurantOrder") as? [String : Int] ?? [String : Int]()
        
        getRestaurants()
        
        setRestaurantIdList()
        
        $noMenuHide
            .sink { hide in
                UserDefaults.standard.set(hide, forKey: "noMenuHide")
            }
            .store(in: &cancellables)
        
        $restaurantIds
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink { [weak self] ids in
                guard let self = self else { return }
                ids.enumerated().forEach { (order, id) in
                    self.restaurantOrder["\(id)"] = order
                }
                
                UserDefaults.standard.set(self.restaurantOrder, forKey: "restaurantOrder")
            }
            .store(in: &cancellables)
        
        $favRestaurantIds
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink { [weak self] ids in
                guard let self = self else { return }
                ids.enumerated().forEach { (order, id) in
                    self.favRestaurantOrder["\(id)"] = order
                }
                
                UserDefaults.standard.set(self.favRestaurantOrder, forKey: "favRestaurantOrder")
            }
            .store(in: &cancellables)
    }
    
    func getRestaurants() {
        networkStatus = .loading
        print("get restaurants")
        
        URLSession.shared.dataTaskPublisher(for: URL(string: "-/restaurants/")!)
            .receive(on: RunLoop.main)
            .sink
            { _ in }
            receiveValue: { [weak self] (data, response) in
                guard let self = self else { return }
                guard let response = response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode,
                      let restJSON = try? JSON(data: data)["result"].array else {
                    self.networkStatus = .failed
                    return
                }
                var restOrder = (UserDefaults.standard.dictionary(forKey: "restaurantOrder") as? [String : Int]) ?? [String : Int]()
                var favRestOrder = (UserDefaults.standard.dictionary(forKey: "favRestaurantOrder") as? [String : Int]) ?? [String : Int]()
                
                restJSON.forEach { json in
                    let id = json["id"].intValue
                    let name = json["name_kr"].stringValue
                    
                    UserDefaults.standard.set(name, forKey: "restName\(id)")
                    
                    if restOrder["\(id)"] == nil {
                        restOrder["\(id)"] = .max
                    }
                    if favRestOrder["\(id)"] == nil, UserDefaults.standard.bool(forKey: "fav\(id)") {
                        favRestOrder["\(id)"] = .max
                    }
                }
                UserDefaults.standard.set(restOrder, forKey: "restaurantOrder")
                UserDefaults.standard.set(favRestOrder, forKey: "favRestaurantOrder")
                
                self.restaurantOrder = restOrder
                self.favRestaurantOrder = favRestOrder
                
                self.setRestaurantIdList()
                
                self.networkStatus = .succeeded
            }
            .store(in: &cancellables)
    }
    
    func setRestaurantIdList() {
        let restOrder = restaurantOrder.sorted { $0.value < $1.value }
        let favRestOrder = favRestaurantOrder.sorted { $0.value < $1.value }
        
        var restIds = [Int]()
        var favRestIds = [Int]()
        
        restOrder.forEach { (id, order) in
            restIds.append(Int(id) ?? 0)
        }
        
        favRestOrder.forEach { (id, order) in
            favRestIds.append(Int(id) ?? 0)
        }
        
        restaurantIds = restIds
        favRestaurantIds = favRestIds.filter { UserDefaults.standard.bool(forKey: "fav\($0)") }
    }
}
