//
//  RestaurantRepositoryImpl.swift
//  Siksha
//
//  Created by 권현구 on 6/3/26.
//

import Foundation

final class RestaurantRepositoryImpl: RestaurantRepositoryProtocol {
    private let remote: RestaurantRemoteDataSource

    init(remote: RestaurantRemoteDataSource = RestaurantRemoteDataSourceImpl()) {
        self.remote = remote
    }

    func fetchPersonalRestaurants() async throws -> [PersonalRestaurantModel] {
        try await remote.fetchPersonalRestaurants()
            .result
            .map { $0.toDomain() }
    }

    func setRestaurantLike(restaurantId: Int, like: Bool) async throws -> RestaurantLikeStatusModel {
        try await remote.setRestaurantLike(restaurantId: restaurantId, like: like)
            .toDomain()
    }

    func setRestaurantVisible(restaurantId: Int, visible: Bool) async throws -> RestaurantVisibilityStatusModel {
        try await remote.setRestaurantVisible(restaurantId: restaurantId, visible: visible)
            .toDomain()
    }

    func fetchRestaurantOrder() async throws -> [Int] {
        try await remote.fetchRestaurantOrder().order
    }

    func setRestaurantOrder(order: [Int]) async throws -> [Int] {
        try await remote.setRestaurantOrder(order: order).order
    }
}

private extension PersonalRestaurantDTO {
    func toDomain() -> PersonalRestaurantModel {
        PersonalRestaurantModel(
            id: id,
            code: code,
            nameKr: nameKr,
            nameEn: nameEn,
            address: addr,
            coordinate: coordinate,
            liked: liked,
            visible: visible,
            operatingHours: operatingHours
        )
    }

    var coordinate: Coordinate? {
        guard let lat, let lng else {
            return nil
        }
        return Coordinate(latitude: lat, longitude: lng)
    }

    var operatingHours: [String] {
        guard let operatingHours = etc?.operatingHours else {
            return []
        }
        return [
            operatingHours.weekdays.joined(separator: "\n").replacingOccurrences(of: "-", with: " - "),
            operatingHours.saturday.joined(separator: "\n").replacingOccurrences(of: "-", with: " - "),
            operatingHours.holiday.joined(separator: "\n").replacingOccurrences(of: "-", with: " - ")
        ]
    }
}

private extension RestaurantLikeResponseDTO {
    func toDomain() -> RestaurantLikeStatusModel {
        RestaurantLikeStatusModel(id: id, liked: liked)
    }
}

private extension RestaurantVisibleResponseDTO {
    func toDomain() -> RestaurantVisibilityStatusModel {
        RestaurantVisibilityStatusModel(id: id, visible: visible)
    }
}
