//
//  MenuRepository.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/19.
//

import Foundation
import RealmSwift
import Combine
import SwiftyJSON

enum MenuError: Error {
    case networkFailure
}

protocol MenuRepositoryProtocol {
    func getMenus(from start: String, to end: String) async throws -> [DailyMenuModel]
}

final class MenuRepository: MenuRepositoryProtocol {
    private var cancellables = Set<AnyCancellable>()
    private let realm = try! Realm()
    
    private let remote: MenuRemoteDataSource
    private let local: MenuLocalDataSource
    
    init(
        remote: MenuRemoteDataSource = MenuRemoteDataSourceImpl(),
        local: MenuLocalDataSource = MenuLocalDataSourceImpl()
    ) {
        self.remote = MenuRemoteDataSourceImpl()
        self.local = MenuLocalDataSourceImpl()
    }
    
    func getMenus(from start: String, to end: String) async throws -> [DailyMenuModel] {
        let dto = try await remote.fetchDailyMenus(from: start, to: end)
        let realmObjects = dto.result.map { $0.toRealmObject() }
        try local.saveDailyMenus(realmObjects)
        
        return try local.fetchDailyMenus(from: start, to: end)
            .map { $0.toModel() }
    }
    
    func fetchFestivalDates() -> AnyPublisher<[Date], Never> {
        Networking.shared.getFestivalDates()
            .map { response in
                guard let value = response.value else {
                    return []
                }
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                return value.festivalDates.compactMap { formatter.date(from: $0) }
            }
            .eraseToAnyPublisher()
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
    
    func getMenuFromID(_ id: String) -> DailyMenu? {
        return realm.object(ofType: DailyMenu.self, forPrimaryKey: id)
    }
    
}
