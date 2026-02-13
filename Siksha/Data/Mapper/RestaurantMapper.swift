//
//  RestaurantMapper.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

enum RestaurantMapper {
    static func toModel(_ dto: RestaurantDTO) -> RestaurantModel {
        let coordinate: Coordinate? = {
            guard let lat = dto.lat, let lng = dto.lng else { return nil }
            return Coordinate(latitude: lat, longitude: lng)
        }()
    
        let operatingHours: [DateType: [String]] = {
            guard let hours = dto.etc?.operatingHours else { return [:] }
            return [
                .weekday: hours.weekdays,
                .saturday: hours.saturday,
                .holiday: hours.holiday
            ]
        }()
        
        return RestaurantModel(
            id: dto.id,
            code: dto.code,
            nameKr: dto.nameKr,
            nameEn: dto.nameEn,
            address: dto.addr,
            coordinate: coordinate,
            menus: dto.menus.map(MenuMapper.toModel),
            operatingHours: operatingHours
        )
    }
}
