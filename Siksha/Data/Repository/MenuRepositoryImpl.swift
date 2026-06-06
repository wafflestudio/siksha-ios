//
//  MenuRepositoryImpl.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/19.
//

import Foundation

enum MenuError: Error {
    case networkFailure
}

final class MenuRepositoryImpl: MenuRepositoryProtocol {
    private let remote: MenuRemoteDataSource
    private let local: MenuLocalDataSource
    
    init(
        remote: MenuRemoteDataSource = MenuRemoteDataSourceImpl(),
        local: MenuLocalDataSource = MenuLocalDataSourceImpl()
    ) {
        self.remote = remote
        self.local = local
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

    func getMenu(date: String) -> DailyMenuModel? {
        try? local.fetchDailyMenu(date: date)?.toModel()
    }
    
}
