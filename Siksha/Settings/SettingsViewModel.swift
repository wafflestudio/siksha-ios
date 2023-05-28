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
    @Published var networkStatus: NetworkStatus = .idle
    @Published var showSignOutAlert: Bool = false
    
    @Published var version: String = ""
    @Published var appStoreVersion: String = ""
    
    var restaurantOrder: [String : Int]
    var favRestaurantOrder: [String : Int]
    
    @Published var showVOC: Bool = false
    @Published var postVOCStatus: NetworkStatus = .idle
    @Published var userId: Int = 0
    @Published var vocComment: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    func getVersion() {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String else {
            return
        }
        self.version = version
    }
    
    func getAppStoreVersion() {
        guard let url = URL(string: "http://itunes.apple.com/lookup?id=1032700617"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            results.count > 0,
            let appStoreVersion = results[0]["version"] as? String
            else { return }
        self.appStoreVersion = appStoreVersion
    }
    
    var isUpdateAvailable: Bool {
        if self.version == self.appStoreVersion && self.version != "" {
            return false
        } else {
            return true
        }
    }
    
    init() {
        noMenuHide = !UserDefaults.standard.bool(forKey: "notNoMenuHide")
        
        restaurantOrder = UserDefaults.standard.dictionary(forKey: "restaurantOrder") as? [String : Int] ?? [String : Int]()
        favRestaurantOrder = UserDefaults.standard.dictionary(forKey: "favRestaurantOrder") as? [String : Int] ?? [String : Int]()
        
        getUserId()
        
        getRestaurants()
        
        setRestaurantIdList()
        
        getVersion()
        getAppStoreVersion()
        
        $noMenuHide
            .sink { hide in
                UserDefaults.standard.set(!hide, forKey: "notNoMenuHide")
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
        
        $postVOCStatus
            .dropFirst()
            .sink { [weak self] status in
                guard let self = self else { return }
                
                self.alertMessage = status == .failed ? "전송에 실패했습니다. 다시 시도해주세요." : "전송했습니다."
                self.showAlert = true
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
    
    func getUserId() {
        Networking.shared.getUserInfo()
            .receive(on: RunLoop.main)
            .map(\.value?.id)
            .replaceNil(with: 0)
            .assign(to: \.userId, on: self)
            .store(in: &cancellables)
    }
    
    func sendVOC() {
        Networking.shared.submitVOC(comment: vocComment, platform: "iOS")
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                guard let response = result.response,
                      200..<300 ~= response.statusCode else {
                    self.postVOCStatus = .failed
                    return
                }
                
                self.postVOCStatus = .succeeded
            }
            .store(in: &cancellables)
    }
}
