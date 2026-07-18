//
//  RestaurantDTO.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

struct RestaurantDTO: Decodable, Sendable {
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

struct PersonalRestaurantsResponseDTO: Decodable, Sendable {
    let count: Int
    let result: [PersonalRestaurantDTO]
}

struct PersonalRestaurantDTO: Codable, Sendable {
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

struct RestaurantLikeResponseDTO: Decodable, Sendable {
    let id: Int
    let liked: Bool
}

struct RestaurantVisibleResponseDTO: Decodable, Sendable {
    let id: Int
    let visible: Bool
}

struct RestaurantOrderResponseDTO: Decodable, Sendable {
    let order: [Int]
}

struct RestaurantEtcDTO: Codable, Sendable {
    let operatingHours: OperatingHoursDTO?
}

struct OperatingHoursDTO: Codable, Sendable {
    let weekdays: [String]
    let saturday: [String]
    let holiday: [String]

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.weekdays = try container.decodeIfPresent([String].self, forKey: .weekdays) ?? []
        self.saturday = try container.decodeIfPresent([String].self, forKey: .saturday) ?? []
        self.holiday = try container.decodeIfPresent([String].self, forKey: .holiday) ?? []
    }

    enum CodingKeys: String, CodingKey { case weekdays, saturday, holiday }
}

private func normalizedOperatingHours(_ operatingHours: OperatingHoursDTO?) -> [String] {
    guard let operatingHours else {
        return ["", "", ""]
    }

    return [
        formattedOperatingHours(operatingHours.weekdays),
        formattedOperatingHours(operatingHours.saturday),
        formattedOperatingHours(operatingHours.holiday),
    ]
}

private func formattedOperatingHours(_ hours: [String]) -> String {
    hours.joined(separator: "\n").replacingOccurrences(of: "-", with: " - ")
}

extension RestaurantDTO {
    func toRealmObject() -> Restaurant {
        return Restaurant(
            id: id,
            code: code,
            nameKr: nameKr ?? "",
            nameEn: nameEn ?? "",
            addr: addr ?? "",
            lat: lat?.description ?? "",
            lng: lng?.description ?? "",
            operatingHours: normalizedOperatingHours(etc?.operatingHours),
            menus: menus.map { $0.toRealmObject() }
        )
    }
}
