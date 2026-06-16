//
//  UpdateRestaurantPreferenceUseCase.swift
//  Siksha
//
//  Created by 권현구 on 6/3/26.
//

protocol UpdateRestaurantPreferenceUseCase {
    func setLiked(
        restaurant: PersonalRestaurantModel,
        liked: Bool
    ) async throws -> RestaurantPreferenceStatusModel

    func setVisible(
        restaurant: PersonalRestaurantModel,
        visible: Bool
    ) async throws -> RestaurantPreferenceStatusModel
}

final class DefaultUpdateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase {
    private let repository: RestaurantRepositoryProtocol

    init(repository: RestaurantRepositoryProtocol) {
        self.repository = repository
    }

    func setLiked(
        restaurant: PersonalRestaurantModel,
        liked: Bool
    ) async throws -> RestaurantPreferenceStatusModel {
        var nextVisible = restaurant.visible

        if liked, !restaurant.visible {
            let visibleStatus = try await repository.setRestaurantVisible(
                restaurantId: restaurant.id,
                visible: true
            )
            nextVisible = visibleStatus.visible
        }

        let likeStatus = try await repository.setRestaurantLike(
            restaurantId: restaurant.id,
            like: liked
        )

        return RestaurantPreferenceStatusModel(
            id: likeStatus.id,
            liked: likeStatus.liked,
            visible: nextVisible
        )
    }

    func setVisible(
        restaurant: PersonalRestaurantModel,
        visible: Bool
    ) async throws -> RestaurantPreferenceStatusModel {
        var nextLiked = restaurant.liked

        if !visible, restaurant.liked {
            let likeStatus = try await repository.setRestaurantLike(
                restaurantId: restaurant.id,
                like: false
            )
            nextLiked = likeStatus.liked
        }

        let visibleStatus = try await repository.setRestaurantVisible(
            restaurantId: restaurant.id,
            visible: visible
        )

        return RestaurantPreferenceStatusModel(
            id: visibleStatus.id,
            liked: nextLiked,
            visible: visibleStatus.visible
        )
    }
}
