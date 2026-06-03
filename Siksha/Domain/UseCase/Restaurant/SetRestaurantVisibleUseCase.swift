//
//  SetRestaurantVisibleUseCase.swift
//  Siksha
//
//  Created by 권현구 on 6/3/26.
//

protocol SetRestaurantVisibleUseCase {
    func execute(restaurantId: Int, visible: Bool) async throws -> RestaurantVisibilityStatusModel
}

final class DefaultSetRestaurantVisibleUseCase: SetRestaurantVisibleUseCase {
    private let repository: RestaurantRepositoryProtocol

    init(repository: RestaurantRepositoryProtocol) {
        self.repository = repository
    }

    func execute(restaurantId: Int, visible: Bool) async throws -> RestaurantVisibilityStatusModel {
        try await repository.setRestaurantVisible(restaurantId: restaurantId, visible: visible)
    }
}
