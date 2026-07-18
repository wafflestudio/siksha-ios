//
//  DailyMenuModel.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

enum DateType {
    case weekdays
    case saturday
    case holiday

    static func getType(from num: Int) -> Self {
        if num == 2 {
            return .holiday
        } else if num == 1 {
            return .saturday
        } else {
            return .weekdays
        }
    }
}

struct DailyMenuModel {
    let date: String
    let dateType: DateType
    let breakfast: [RestaurantModel]
    let lunch: [RestaurantModel]
    let dinner: [RestaurantModel]
}
