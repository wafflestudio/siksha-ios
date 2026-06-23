//
//  MealInfoUseCase.swift
//  Siksha
//
//  Created by Codex on 6/7/26.
//

protocol MealInfoUseCase {
    func fetchMenu(menuId: Int) async throws -> MenuModel
    func toggleMenuLike(menu: MenuModel) async throws -> MenuModel
}

final class DefaultMealInfoUseCase: MealInfoUseCase {
    private let repository: MealInfoRepositoryProtocol
    
    init(repository: MealInfoRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchMenu(menuId: Int) async throws -> MenuModel {
        try await repository.fetchMenu(menuId: menuId)
    }
    
    func toggleMenuLike(menu: MenuModel) async throws -> MenuModel {
        if menu.isLiked {
            return try await repository.unlikeMenu(menuId: menu.id)
        }
        return try await repository.likeMenu(menuId: menu.id)
    }
}
