//
//  MenuRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 6/7/26.
//

protocol MenuRepositoryProtocol: Sendable {
    @concurrent
    func refreshMenu(date: String) async throws -> Bool

    @concurrent
    func getMenus(from start: String, to end: String) async throws -> [DailyMenuModel]
    func getMenu(date: String) -> DailyMenuModel?
}
