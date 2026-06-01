//
//  RestaurantRemoteDataSource.swift
//  Siksha
//
//  Created by 권현구 on 6/1/26.
//

import Foundation
import Alamofire

protocol RestaurantRemoteDataSource {
    func fetchPersonalRestaurants() async throws -> PersonalRestaurantsResponseDTO
    func setRestaurantLike(restaurantId: Int, like: Bool) async throws -> RestaurantLikeResponseDTO
    func setRestaurantVisible(restaurantId: Int, visible: Bool) async throws -> RestaurantVisibleResponseDTO
    func fetchRestaurantOrder() async throws -> RestaurantOrderResponseDTO
    func setRestaurantOrder(order: [Int]) async throws -> RestaurantOrderResponseDTO
}

final class RestaurantRemoteDataSourceImpl: RestaurantRemoteDataSource {
    func fetchPersonalRestaurants() async throws -> PersonalRestaurantsResponseDTO {
        try await AF
            .request(SikshaAPI.getPersonalRestaurants)
            .validate()
            .serializingDecodable(PersonalRestaurantsResponseDTO.self, decoder: NetworkDecoder.make())
            .value
    }

    func setRestaurantLike(restaurantId: Int, like: Bool) async throws -> RestaurantLikeResponseDTO {
        try await AF
            .request(SikshaAPI.setRestaurantLike(restaurantId: restaurantId, like: like))
            .validate()
            .serializingDecodable(RestaurantLikeResponseDTO.self, decoder: NetworkDecoder.make())
            .value
    }

    func setRestaurantVisible(restaurantId: Int, visible: Bool) async throws -> RestaurantVisibleResponseDTO {
        try await AF
            .request(SikshaAPI.setRestaurantVisible(restaurantId: restaurantId, visible: visible))
            .validate()
            .serializingDecodable(RestaurantVisibleResponseDTO.self, decoder: NetworkDecoder.make())
            .value
    }

    func fetchRestaurantOrder() async throws -> RestaurantOrderResponseDTO {
        try await AF
            .request(SikshaAPI.getRestaurantOrder)
            .validate()
            .serializingDecodable(RestaurantOrderResponseDTO.self, decoder: NetworkDecoder.make())
            .value
    }

    func setRestaurantOrder(order: [Int]) async throws -> RestaurantOrderResponseDTO {
        try await AF
            .request(SikshaAPI.setRestaurantOrder(order: order))
            .validate()
            .serializingDecodable(RestaurantOrderResponseDTO.self, decoder: NetworkDecoder.make())
            .value
    }
}
