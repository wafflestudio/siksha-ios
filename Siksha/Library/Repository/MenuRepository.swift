//
//  MenuRepository.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/19.
//

import Foundation
import Realm
import RealmSwift
import Combine
import SwiftyJSON

final class MenuRepository {
    @Published var dailyMenus = [DailyMenu]()
    
    private var cancellables = Set<AnyCancellable>()
    
    private let realm = try! Realm()
    
    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // delete menus that have been passed already
        try! realm.write{
            realm.delete(realm.objects(DailyMenu.self).filter{ formatter.date(from: $0.date)?.timeIntervalSince(Date()) ?? -1 < -3600*24 })
        }
        
        realm.objects(DailyMenu.self).forEach { menu in
            dailyMenus.append(menu)
        }
    }
    
    func getMenuPublisher(startDate: String, endDate: String) -> AnyPublisher<URLSession.DataTaskPublisher.Output, URLSession.DataTaskPublisher.Failure> {
        let url = Config.shared.baseURL + "/menus/"
        
        var component = URLComponents(string: url)
        var parameters = [URLQueryItem]()
        
        parameters.append(URLQueryItem(name: "start_date", value: startDate))
        parameters.append(URLQueryItem(name: "end_date", value: endDate))
        parameters.append(URLQueryItem(name: "except_empty", value: UserDefaults.standard.bool(forKey: "noMenuHide") ? "true" : "false"))
        
        component?.queryItems = parameters
        
        let request = URLRequest(url: component?.url ?? URL(string: url)!)
        
        let publisher = URLSession.shared.dataTaskPublisher(for: request)
            .share()
            .eraseToAnyPublisher()
            
        publisher
            .receive(on: RunLoop.main)
            .sink { _ in }
                receiveValue: { [weak self] (data, response) in
                    guard let self = self else { return }
                    guard let response = response as? HTTPURLResponse,
                          200..<300 ~= response.statusCode,
                          let jsonArray = try? JSON(data: data)["result"].array else {
                        return
                    }
                    try! self.realm.write {
                        jsonArray.forEach { json in
                            let newMenu = DailyMenu(json)
                            self.dailyMenus.removeAll { $0.date == newMenu.date }
                            self.dailyMenus.append(newMenu)
                            
                            self.realm.add(newMenu, update: .modified)
                        }
                    }
                }
            .store(in: &cancellables)
        
        return publisher
    }
}
