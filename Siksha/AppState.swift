
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

public class AppState: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var showSheet: Bool = false
    @Published var showRestaurantInfo: Bool = false
    @Published var showMealInfo: Bool = false
    @Published var restaurantToShow: Restaurant? = nil
    @Published var mealToShow: Meal? = nil
    @Published var canSubmitReview: Bool = true
    @Published var monthToShow: Int? = nil
    @Published var showCalendar: Bool = false
    
    @Published var ratingEnabled: Bool = true

    init(){
        let token = UserDefaults.standard.string(forKey: "accessToken")
        let exp = UserDefaults.standard.double(forKey: "tokenExpDate")
        
        let expDate = Date(timeIntervalSince1970: exp)
        
        if DateInterval(start: Date(), end: expDate).duration < TimeInterval(15552000) { // 6 month
            let url = Config.shared.baseURL + "/auth/refresh"
            
            if var request = try? URLRequest(url: url, method: .post), let token = token {
                print("refresh")
                request.setToken(token: token)
                
                URLSession.shared.dataTaskPublisher(for: request)
                    .receive(on: RunLoop.main)
                    .sink { _ in }
                        receiveValue: { (data, response) in
                            guard let response = response as? HTTPURLResponse,
                                  200..<300 ~= response.statusCode,
                                  let accessToken = try? JSON(data: data)["access_token"].stringValue,
                                  let expDate = Utils.shared.decode(jwtToken: accessToken)["exp"] as? Double else {
                                return
                            }
                            
                            print(expDate)
                            print(accessToken)
                            
                            UserDefaults.standard.set(expDate, forKey: "tokenExpDate")
                            UserDefaults.standard.set(accessToken, forKey: "accessToken")
                            
                        }
                    .store(in: &cancellables)
            }
        }
        
        $showSheet
            .filter { !$0 }
            .sink { [weak self] _ in
                self?.restaurantToShow = nil
                self?.mealToShow = nil
            }
            .store(in: &cancellables)
        
        $restaurantToShow
            .filter { $0 != nil }
            .sink { [weak self] restaurant in
                guard let self = self else { return }
                self.showSheet = true
            }
            .store(in: &cancellables)
        
        $mealToShow
            .filter { $0 != nil }
            .sink { [weak self] meal in
                guard let self = self else { return }
                self.showSheet = true
            }
            .store(in: &cancellables)
        
        $monthToShow
            .filter { $0 != nil }
            .sink { [weak self] meal in
                guard let self = self else { return }
                self.showCalendar = true
            }
            .store(in: &cancellables)
        
        $showRestaurantInfo
            .filter { !$0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.restaurantToShow = nil
            }
            .store(in: &cancellables)
        
        $showMealInfo
            .filter { !$0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.mealToShow = nil
            }
            .store(in: &cancellables)
        
        $showCalendar
            .filter { !$0 }
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.monthToShow = nil
            }
            .store(in: &cancellables)
        
    }
}
