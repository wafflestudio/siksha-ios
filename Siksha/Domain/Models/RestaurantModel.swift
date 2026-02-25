//
//  RestaurantModel.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

struct RestaurantModel {
    let id: Int
    let code: String
    let nameKr: String?
    let nameEn: String?
    let address: String?
    let coordinate: Coordinate?
    let menus: [MenuModel]
    let operatingHours: [String]
}
