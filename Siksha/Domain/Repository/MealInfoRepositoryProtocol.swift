//
//  MealInfoRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 6/7/26.
//

import Foundation

protocol MealInfoRepositoryProtocol {
    func fetchMenu(menuId: Int) async throws -> MenuModel
    func likeMenu(menuId: Int) async throws -> MenuModel
    func unlikeMenu(menuId: Int) async throws -> MenuModel
}
