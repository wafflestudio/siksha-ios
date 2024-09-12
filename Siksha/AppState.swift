
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
    
    init(){
        let token = UserDefaults.standard.string(forKey: "accessToken")
        let exp = UserDefaults.standard.double(forKey: "tokenExpDate")
        
        let expDate = Date(timeIntervalSince1970: exp)
        
        if DateInterval(start: Date(), end: expDate).duration < TimeInterval(15552000), let token = token { // 6 month
            Networking.shared.refreshAccessToken(token: token)
                .receive(on: RunLoop.main)
                .sink { _ in }
                    receiveValue: { response in
                        guard let data = response.value,
                            let accessToken = try? JSON(data: data)["access_token"].stringValue,
                            let expDate = Utils.shared.decode(jwtToken: accessToken)["exp"] as? Double else {
                            return
                        }
                        
                        #if DEBUG
                        print(expDate)
                        print(accessToken)
                        #endif
                        
                        UserDefaults.standard.set(expDate, forKey: "tokenExpDate")
                        UserDefaults.standard.set(accessToken, forKey: "accessToken")
                        
                    }
                .store(in: &cancellables)
        }
    }
}
