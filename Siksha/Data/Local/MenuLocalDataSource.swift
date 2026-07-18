//
//  MenuLocalDataSource.swift
//  Siksha
//
//  Created by Jihyeon on 2/23/26.
//

import Combine
import Foundation
import RealmSwift

protocol MenuLocalDataSource {
    func saveDailyMenus(_ menus: [DailyMenu]) throws
    func fetchDailyMenus(from start: String, to end: String) throws -> [DailyMenu]
    func fetchDailyMenu(date: String) throws -> DailyMenu?
    func deleteAll() throws
}

final class MenuLocalDataSourceImpl: MenuLocalDataSource {
    private func getRealm() throws -> Realm {
        do {
            return try Realm()
        } catch {
            print("Realm 초기화 실패: \(error)")
            throw error
        }
    }

    func saveDailyMenus(_ menus: [DailyMenu]) throws {
        let realm = try getRealm()

        try realm.write {
            realm.add(menus, update: .modified)
        }
    }

    func fetchDailyMenus(from start: String, to end: String) throws -> [DailyMenu] {
        let realm = try getRealm()

        let results = realm.objects(DailyMenu.self)
            .filter("date >= %@ AND date <= %@", start, end)
            .sorted(byKeyPath: "date", ascending: true)
        return Array(results)
    }

    func fetchDailyMenu(date: String) throws -> DailyMenu? {
        let realm = try getRealm()

        return realm.object(ofType: DailyMenu.self, forPrimaryKey: date)
    }

    func deleteAll() throws {
        let realm = try getRealm()

        try realm.write {
            realm.deleteAll()
        }
    }
}
