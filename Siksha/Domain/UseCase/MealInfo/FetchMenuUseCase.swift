//
//  FetchMenuUseCase.swift
//  Siksha
//
//  Created by Codex on 6/7/26.
//

protocol FetchMenuUseCase {
    func execute(menuId: Int) async throws -> MenuModel
}

final class DefaultFetchMenuUseCase: FetchMenuUseCase {
    private let repository: MealInfoRepositoryProtocol
    
    init(repository: MealInfoRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(menuId: Int) async throws -> MenuModel {
        try await repository.fetchMenu(menuId: menuId)
    }
}
