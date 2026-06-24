//
//  MenuPreferenceRepositoryImpl.swift
//  Siksha
//
//  Created by Codex on 6/24/26.
//

final class MenuPreferenceRepositoryImpl: MenuPreferenceRepositoryProtocol {
    private let remote: MenuPreferenceRemoteDataSource
    
    init(remote: MenuPreferenceRemoteDataSource = MenuPreferenceRemoteDataSourceImpl()) {
        self.remote = remote
    }
    
    func likeMenu(menuId: Int) async throws -> MenuLikeStatusModel {
        try await remote.likeMenu(menuId: menuId).toDomain()
    }
    
    func unlikeMenu(menuId: Int) async throws -> MenuLikeStatusModel {
        try await remote.unlikeMenu(menuId: menuId).toDomain()
    }
}

private extension MenuLikeStatusDTO {
    func toDomain() -> MenuLikeStatusModel {
        MenuLikeStatusModel(
            menuId: menuId,
            isLiked: isLiked,
            likeCount: likeCount
        )
    }
}
