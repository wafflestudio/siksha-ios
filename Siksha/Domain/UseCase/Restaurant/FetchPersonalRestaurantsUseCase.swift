//
//  FetchPersonalRestaurantsUseCase.swift
//  Siksha
//
//  Created by 권현구 on 6/3/26.
//

protocol FetchPersonalRestaurantsUseCase {
    func execute() async throws -> [PersonalRestaurantModel]
}

final class DefaultFetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase {
    private let repository: RestaurantRepositoryProtocol

    init(repository: RestaurantRepositoryProtocol) {
        self.repository = repository
    }

    func execute() async throws -> [PersonalRestaurantModel] {
        try await repository.fetchPersonalRestaurants()
    }
}
