//
//  DailyMenusMapper.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

enum DailyMenusMapper {
    static func toModel(_ dto: DailyMenusDTO) -> DailyMenus {
        DailyMenus(
            date: dto.date,
            dateType: DateTypeMapper.toModel(dto.dateType),
            breakfast: dto.br.map(RestaurantMapper.toModel),
            lunch: dto.lu.map(RestaurantMapper.toModel),
            dinner: dto.dn.map(RestaurantMapper.toModel)
        )
    }
}
