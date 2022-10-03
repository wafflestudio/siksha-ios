//
//  FavoriteRestaurantOrderViewModel.swift
//  Siksha
//
//  Created by 한상현 on 2022/10/03.
//

import Foundation
import Combine
import SwiftyJSON

class FavoriteRestaurantOrderViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var networkStatus: NetworkStatus = .idle
    
    @Published var favRestaurantIds = [Int]()
    var favRestaurantOrder: [String : Int]
    
    init() {
        favRestaurantOrder = UserDefaults.standard.dictionary(forKey: "favRestaurantOrder") as? [String : Int] ?? [String : Int]()
        
        getRestaurants()
        setRestaurantIdList()
        
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
                
                self.favRestaurantOrder = favRestOrder
                
                self.setRestaurantIdList()
                
                self.networkStatus = .succeeded
            }
            .store(in: &cancellables)
    }
    
    func setRestaurantIdList() {
        let favRestOrder = favRestaurantOrder.sorted { $0.value < $1.value }
        
        var favRestIds = [Int]()
        
        favRestOrder.forEach { (id, order) in
            favRestIds.append(Int(id) ?? 0)
        }
        
        favRestaurantIds = favRestIds.filter { UserDefaults.standard.bool(forKey: "fav\($0)") }
    }
}
