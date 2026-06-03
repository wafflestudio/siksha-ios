//
//  RestaurantRepositoryProtocol.swift
//  Siksha
//
//  Created by 권현구 on 6/3/26.
//

import Foundation

protocol RestaurantRepositoryProtocol {
    func fetchPersonalRestaurants() async throws -> [PersonalRestaurantModel]
    func setRestaurantLike(restaurantId: Int, like: Bool) async throws -> RestaurantLikeStatusModel
    func setRestaurantVisible(restaurantId: Int, visible: Bool) async throws -> RestaurantVisibilityStatusModel
    func fetchRestaurantOrder() async throws -> [Int]
    func setRestaurantOrder(order: [Int]) async throws -> [Int]
}
