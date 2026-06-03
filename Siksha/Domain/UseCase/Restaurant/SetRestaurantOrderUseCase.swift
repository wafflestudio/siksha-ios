//
//  SetRestaurantOrderUseCase.swift
//  Siksha
//
//  Created by 권현구 on 6/3/26.
//

protocol SetRestaurantOrderUseCase {
    func execute(order: [Int]) async throws -> [Int]
}

final class DefaultSetRestaurantOrderUseCase: SetRestaurantOrderUseCase {
    private let repository: RestaurantRepositoryProtocol

    init(repository: RestaurantRepositoryProtocol) {
        self.repository = repository
    }

    func execute(order: [Int]) async throws -> [Int] {
        try await repository.setRestaurantOrder(order: order)
    }
}
