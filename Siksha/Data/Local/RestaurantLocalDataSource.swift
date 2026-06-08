//
//  RestaurantLocalDataSource.swift
//  Siksha
//
//  Created by Codex on 6/8/26.
//

import Foundation

protocol RestaurantLocalDataSource {
    func savePersonalRestaurants(_ restaurants: [PersonalRestaurantDTO])
    func fetchPersonalRestaurants() -> [PersonalRestaurantDTO]?
    func updateRestaurantLike(restaurantId: Int, liked: Bool)
    func updateRestaurantVisible(restaurantId: Int, visible: Bool)
    func updateRestaurantOrder(_ order: [Int])
}

final class RestaurantLocalDataSourceImpl: RestaurantLocalDataSource {
    private enum Key {
        static let personalRestaurants = "personalRestaurantsCache"
    }

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func savePersonalRestaurants(_ restaurants: [PersonalRestaurantDTO]) {
        guard let data = try? encoder.encode(restaurants) else {
            return
        }
        userDefaults.set(data, forKey: Key.personalRestaurants)
    }

    func fetchPersonalRestaurants() -> [PersonalRestaurantDTO]? {
        guard let data = userDefaults.data(forKey: Key.personalRestaurants),
              let restaurants = try? decoder.decode([PersonalRestaurantDTO].self, from: data) else {
            return nil
        }
        return restaurants
    }

    func updateRestaurantLike(restaurantId: Int, liked: Bool) {
        updateRestaurant(restaurantId: restaurantId) { restaurant in
            PersonalRestaurantDTO(
                createdAt: restaurant.createdAt,
                updatedAt: restaurant.updatedAt,
                id: restaurant.id,
                code: restaurant.code,
                nameKr: restaurant.nameKr,
                nameEn: restaurant.nameEn,
                addr: restaurant.addr,
                lat: restaurant.lat,
                lng: restaurant.lng,
                liked: liked,
                visible: restaurant.visible,
                etc: restaurant.etc
            )
        }
    }

    func updateRestaurantVisible(restaurantId: Int, visible: Bool) {
        updateRestaurant(restaurantId: restaurantId) { restaurant in
            PersonalRestaurantDTO(
                createdAt: restaurant.createdAt,
                updatedAt: restaurant.updatedAt,
                id: restaurant.id,
                code: restaurant.code,
                nameKr: restaurant.nameKr,
                nameEn: restaurant.nameEn,
                addr: restaurant.addr,
                lat: restaurant.lat,
                lng: restaurant.lng,
                liked: restaurant.liked,
                visible: visible,
                etc: restaurant.etc
            )
        }
    }

    func updateRestaurantOrder(_ order: [Int]) {
        guard let cachedRestaurants = fetchPersonalRestaurants() else {
            return
        }

        let restaurantById = Dictionary(uniqueKeysWithValues: cachedRestaurants.map { ($0.id, $0) })
        var orderedRestaurants = order.compactMap { restaurantById[$0] }
        let orderedRestaurantIds = Set(order)
        orderedRestaurants.append(contentsOf: cachedRestaurants.filter { !orderedRestaurantIds.contains($0.id) })
        savePersonalRestaurants(orderedRestaurants)
    }

    private func updateRestaurant(
        restaurantId: Int,
        transform: (PersonalRestaurantDTO) -> PersonalRestaurantDTO
    ) {
        guard var cachedRestaurants = fetchPersonalRestaurants(),
              let index = cachedRestaurants.firstIndex(where: { $0.id == restaurantId }) else {
            return
        }

        cachedRestaurants[index] = transform(cachedRestaurants[index])
        savePersonalRestaurants(cachedRestaurants)
    }
}
