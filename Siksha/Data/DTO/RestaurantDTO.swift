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

struct PersonalRestaurantsResponseDTO: Decodable {
    let count: Int
    let result: [PersonalRestaurantDTO]
}

struct PersonalRestaurantDTO: Decodable {
    let createdAt: Date
    let updatedAt: Date
    let id: Int
    let code: String
    let nameKr: String?
    let nameEn: String?
    let addr: String?
    let lat: Double?
    let lng: Double?
    let liked: Bool
    let visible: Bool
    let etc: RestaurantEtcDTO?
}

struct RestaurantLikeResponseDTO: Decodable {
    let id: Int
    let liked: Bool
}

struct RestaurantVisibleResponseDTO: Decodable {
    let id: Int
    let visible: Bool
}

struct RestaurantOrderResponseDTO: Decodable {
    let order: [Int]
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

extension RestaurantDTO {
    func toRealmObject() -> Restaurant {
        var operatingHours = [String]()
        if let operatingHoursData = etc?.operatingHours {
            operatingHours.append(operatingHoursData.weekdays.joined(separator: "\n").replacingOccurrences(of: "-", with: " - "))
            operatingHours.append(operatingHoursData.saturday.joined(separator: "\n").replacingOccurrences(of: "-", with: " - "))
            operatingHours.append(operatingHoursData.holiday.joined(separator: "\n").replacingOccurrences(of: "-", with: " - "))
        }
        
        return Restaurant(
            id: id,
            code: code,
            nameKr: nameKr ?? "",
            nameEn: nameEn ?? "",
            addr: addr ?? "",
            lat: lat?.description ?? "",
            lng: lng?.description ?? "",
            operatingHours: operatingHours,
            menus: menus.map { $0.toRealmObject() }
        )
    }
}
