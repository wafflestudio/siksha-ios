//
//  MenuRepository.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/19.
//

import Foundation
import RealmSwift

enum MenuError: Error {
    case networkFailure
}

protocol MenuRepositoryProtocol {
    func refreshMenu(date: String) async throws -> Bool
    func getMenus(from start: String, to end: String) async throws -> [DailyMenuModel]
    func getMenu(date: String) -> DailyMenu?
}

final class MenuRepository: MenuRepositoryProtocol {
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
    
    func refreshMenu(date: String) async throws -> Bool {
        let dto = try await remote.fetchDailyMenus(from: date, to: date)
        guard !dto.result.isEmpty else {
            return false
        }
        
        let realmObjects = dto.result.map { $0.toRealmObject() }
        try local.saveDailyMenus(realmObjects)
        
        return true
    }
    
    func getMenus(from start: String, to end: String) async throws -> [DailyMenuModel] {
        let dto = try await remote.fetchDailyMenus(from: start, to: end)
        let realmObjects = dto.result.map { $0.toRealmObject() }
        try local.saveDailyMenus(realmObjects)
        
        return try local.fetchDailyMenus(from: start, to: end)
            .map { $0.toModel() }
    }

    func getMenu(date: String) -> DailyMenu? {
        realm.object(ofType: DailyMenu.self, forPrimaryKey: date)
    }
    
    func getMenuFromID(_ id: String) -> DailyMenu? {
        return realm.object(ofType: DailyMenu.self, forPrimaryKey: id)
    }
    
}
