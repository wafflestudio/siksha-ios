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

enum MenuError: Error {
    case networkFailure
}

final class MenuRepository {
    private var cancellables = Set<AnyCancellable>()
    
    private let realm = try! Realm()
    
    init() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        // delete menus that have been passed already
//        try! realm.write{
//            realm.delete(realm.objects(DailyMenu.self).filter{ formatter.date(from: $0.date)?.timeIntervalSince(Date()) ?? -1 < -3600*24 })
//        }
    }
    
    func fetchMenu(date: String) -> AnyPublisher<MenuStatus, Never> {
        Networking.shared.getMenus(startDate: date, endDate: date, noMenuHide: false) // 메뉴가 없는 식당까지 모두 가져옴
            // Save menus to db
            .handleEvents(receiveOutput: { response in
                guard let data = response.value,
                      let jsonArray = try? JSON(data: data)["result"].array else {
                    return
                }
                
                try! self.realm.write {
                    jsonArray.forEach { json in
                        let newMenu = DailyMenu(json)
                        
                        self.realm.add(newMenu, update: .modified)
                    }
                }
            })
            .map { response in
                if response.data == nil {
                    return MenuStatus.showCached
                } else {
                    return MenuStatus.succeeded
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getMenu(date: String) -> DailyMenu? {
        let menus = realm.objects(DailyMenu.self).filter("date CONTAINS '\(date)'")
        
        if menus.count == 0 {
            return nil
        }
        
        return menus[0]
    }
}
