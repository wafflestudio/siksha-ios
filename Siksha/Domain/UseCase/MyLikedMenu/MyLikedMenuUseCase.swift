//
//  MyLikedMenuUseCase.swift
//  Siksha
//
//  Created by Codex on 6/24/26.
//

protocol MyLikedMenuUseCase {
    func fetchMyLikedMenus() async throws -> [RestaurantLikedMenuGroup]
}

final class DefaultMyLikedMenuUseCase: MyLikedMenuUseCase {
    private let repository: MyLikedMenuRepositoryProtocol
    
    init(repository: MyLikedMenuRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchMyLikedMenus() async throws -> [RestaurantLikedMenuGroup] {
        try await repository.fetchMyLikedMenus()
    }
}
