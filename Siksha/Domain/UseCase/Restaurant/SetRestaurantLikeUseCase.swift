//
//  SetRestaurantLikeUseCase.swift
//  Siksha
//
//  Created by 권현구 on 6/3/26.
//

protocol SetRestaurantLikeUseCase {
    func execute(restaurantId: Int, like: Bool) async throws -> RestaurantLikeStatusModel
}

final class DefaultSetRestaurantLikeUseCase: SetRestaurantLikeUseCase {
    private let repository: RestaurantRepositoryProtocol

    init(repository: RestaurantRepositoryProtocol) {
        self.repository = repository
    }

    func execute(restaurantId: Int, like: Bool) async throws -> RestaurantLikeStatusModel {
        try await repository.setRestaurantLike(restaurantId: restaurantId, like: like)
    }
}
