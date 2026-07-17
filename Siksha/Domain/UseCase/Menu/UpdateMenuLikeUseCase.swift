//
//  UpdateMenuLikeUseCase.swift
//  Siksha
//
//  Created by Codex on 6/26/26.
//

protocol UpdateMenuLikeUseCase {
    func execute(menuId: Int, isLiked: Bool) async throws -> MenuLikeStatusModel
}

final class DefaultUpdateMenuLikeUseCase: UpdateMenuLikeUseCase {
    private let repository: MenuPreferenceRepositoryProtocol

    init(repository: MenuPreferenceRepositoryProtocol) {
        self.repository = repository
    }

    func execute(menuId: Int, isLiked: Bool) async throws -> MenuLikeStatusModel {
        if isLiked {
            try await repository.likeMenu(menuId: menuId)
        } else {
            try await repository.unlikeMenu(menuId: menuId)
        }
    }
}
