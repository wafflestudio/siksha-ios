//
//  DailyMenusDTO.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

struct DailyMenusDTO: Decodable {
    let date: String
    let dateType: String
    let br: [RestaurantDTO]
    let lu: [RestaurantDTO]
    let dn: [RestaurantDTO]
}
