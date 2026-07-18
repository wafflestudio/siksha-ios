//
//  PersonalRestaurantModel.swift
//  Siksha
//
//  Created by 권현구 on 6/3/26.
//

import Foundation

struct PersonalRestaurantModel: Sendable {
    let id: Int
    let code: String
    let nameKr: String?
    let nameEn: String?
    let address: String?
    let coordinate: Coordinate?
    let liked: Bool
    let visible: Bool
    let operatingHours: [String]
}

struct RestaurantLikeStatusModel: Sendable {
    let id: Int
    let liked: Bool
}

struct RestaurantVisibilityStatusModel: Sendable {
    let id: Int
    let visible: Bool
}
