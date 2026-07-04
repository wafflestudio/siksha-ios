//
//  MenuPreferenceRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 6/24/26.
//

protocol MenuPreferenceRepositoryProtocol {
    func likeMenu(menuId: Int) async throws -> MenuLikeStatusModel
    func unlikeMenu(menuId: Int) async throws -> MenuLikeStatusModel
}
