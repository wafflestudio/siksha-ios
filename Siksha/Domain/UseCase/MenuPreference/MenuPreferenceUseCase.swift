//
//  MenuPreferenceUseCase.swift
//  Siksha
//
//  Created by Codex on 6/24/26.
//

protocol MenuPreferenceUseCase {
    func likeMenu(menuId: Int) async throws -> MenuLikeStatusModel
    func unlikeMenu(menuId: Int) async throws -> MenuLikeStatusModel
}

final class DefaultMenuPreferenceUseCase: MenuPreferenceUseCase {
    private let repository: MenuPreferenceRepositoryProtocol
    
    init(repository: MenuPreferenceRepositoryProtocol) {
        self.repository = repository
    }
    
    func likeMenu(menuId: Int) async throws -> MenuLikeStatusModel {
        try await repository.likeMenu(menuId: menuId)
    }
    
    func unlikeMenu(menuId: Int) async throws -> MenuLikeStatusModel {
        try await repository.unlikeMenu(menuId: menuId)
    }
}
