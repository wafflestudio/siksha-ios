//
//  FetchMyLikedMenusUseCase.swift
//  Siksha
//
//  Created by Codex on 6/24/26.
//

protocol FetchMyLikedMenusUseCase {
    func execute() async throws -> [RestaurantLikedMenuGroup]
}

final class DefaultFetchMyLikedMenusUseCase: FetchMyLikedMenusUseCase {
    private let repository: MyLikedMenuRepositoryProtocol
    
    init(repository: MyLikedMenuRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute() async throws -> [RestaurantLikedMenuGroup] {
        try await repository.fetchMyLikedMenus()
    }
}
