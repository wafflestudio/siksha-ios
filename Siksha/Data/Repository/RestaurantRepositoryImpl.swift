//
//  RestaurantRepositoryImpl.swift
//  Siksha
//
//  Created by 권현구 on 6/3/26.
//

import Foundation

final class RestaurantRepositoryImpl: RestaurantRepositoryProtocol {
    private let remote: RestaurantRemoteDataSource
    private let local: RestaurantLocalDataSource

    init(
        remote: RestaurantRemoteDataSource,
        local: RestaurantLocalDataSource
    ) {
        self.remote = remote
        self.local = local
    }

    func fetchPersonalRestaurants() async throws -> [PersonalRestaurantModel] {
        do {
            let response = try await remote.fetchPersonalRestaurants()
            local.savePersonalRestaurants(response.result)
            return response.result.map { $0.toDomain() }
        } catch {
            guard let cachedRestaurants = local.fetchPersonalRestaurants() else {
                throw error
            }
            return cachedRestaurants.map { $0.toDomain() }
        }
    }

    func setRestaurantLike(restaurantId: Int, like: Bool) async throws -> RestaurantLikeStatusModel {
        let status = try await remote.setRestaurantLike(restaurantId: restaurantId, like: like)
            .toDomain()
        local.updateRestaurantLike(restaurantId: status.id, liked: status.liked)
        return status
    }

    func setRestaurantVisible(restaurantId: Int, visible: Bool) async throws -> RestaurantVisibilityStatusModel {
        let status = try await remote.setRestaurantVisible(restaurantId: restaurantId, visible: visible)
            .toDomain()
        local.updateRestaurantVisible(restaurantId: status.id, visible: status.visible)
        return status
    }

    func fetchRestaurantOrder() async throws -> [Int] {
        do {
            return try await remote.fetchRestaurantOrder().order
        } catch {
            guard let cachedRestaurants = local.fetchPersonalRestaurants() else {
                throw error
            }
            return cachedRestaurants.map(\.id)
        }
    }

    func setRestaurantOrder(order: [Int]) async throws -> [Int] {
        let order = try await remote.setRestaurantOrder(order: order).order
        local.updateRestaurantOrder(order)
        return order
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
            return ["", "", ""]
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
