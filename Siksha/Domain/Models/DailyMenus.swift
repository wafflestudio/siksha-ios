//
//  DailyMenus.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

struct DailyMenus {
    let date: Date
    let dateType: DateType
    let breakfast: [RestaurantModel]
    let lunch: [RestaurantModel]
    let dinner: [RestaurantModel]
}
