//
//  FetchRestaurantOrderUseCase.swift
//  Siksha
//
//  Created by 권현구 on 6/3/26.
//

protocol FetchRestaurantOrderUseCase {
    func execute() async throws -> [Int]
}

final class DefaultFetchRestaurantOrderUseCase: FetchRestaurantOrderUseCase {
    private let repository: RestaurantRepositoryProtocol

    init(repository: RestaurantRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [Int] {
        try await repository.fetchRestaurantOrder()
    }
}
