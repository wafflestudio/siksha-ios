//
//  RestaurantDTO.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

struct RestaurantDTO: Decodable {
    let createdAt: Date
    let updatedAt: Date
    let id: Int
    let code: String
    let nameKr: String?
    let nameEn: String?
    let addr: String?
    let lat: Double?
    let lng: Double?
    let etc: RestaurantEtcDTO?
    let menus: [MenuDTO]
}

struct RestaurantEtcDTO: Decodable {
    let operatingHours: OperatingHoursDTO?
}

struct OperatingHoursDTO: Decodable {
    let weekdays: [String]
    let saturday: [String]
    let holiday: [String]
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.weekdays = try container.decodeIfPresent([String].self, forKey: .weekdays) ?? []
        self.saturday = try container.decodeIfPresent([String].self, forKey: .saturday) ?? []
        self.holiday = try container.decodeIfPresent([String].self, forKey: .holiday) ?? []
    }
    
    enum CodingKeys: String, CodingKey { case weekdays, saturday , holiday }
}
