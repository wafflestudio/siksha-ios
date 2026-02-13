//
//  DailyMenusDTO.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

struct DailyMenusDTO: Decodable {
    let date: Date
    let dateType: String
    let br: [RestaurantDTO]
    let lu: [RestaurantDTO]
    let dn: [RestaurantDTO]
}
