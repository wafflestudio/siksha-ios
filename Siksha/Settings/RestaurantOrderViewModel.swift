//
//  RestaurantOrderViewModel.swift
//  Siksha
//
//  Created by 박정헌 on 2023/06/25.
//

//
//  SettingsViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import Combine
import SwiftyJSON

class RestaurantOrderViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var restaurantIds = [Int]()
    @Published var favRestaurantIds = [Int]()
    @Published var networkStatus: NetworkStatus = .idle
   
    var restaurantOrder: [String : Int] =  (UserDefaults.standard.dictionary(forKey: "restaurantOrder") as? [String : Int]) ?? [String : Int]()
    var favRestaurantOrder: [String : Int] = (UserDefaults.standard.dictionary(forKey: "favRestaurantOrder") as? [String : Int]) ?? [String : Int]()
    
    func bind(){
        $restaurantIds
            .debounce(for: 1, scheduler: RunLoop.main)
            .sink { [weak self] ids in
                guard let self = self else { return }
                ids.enumerated().forEach { (order, id) in
                    self.restaurantOrder["\(id)"] = order
                }
             
                UserDefaults.standard.setValue(self.restaurantOrder, forKey: "restaurantOrder")
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
    func loadRestaurants() {
        networkStatus = .loading
        
        Networking.shared.getRestaurants()
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                guard let data = result.value,
                      let restJSON = try? JSON(data: data)["result"].array else {
                    print("Failure")
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
                    if favRestOrder["\(id)"] == nil {
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
