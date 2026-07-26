//
//  MyLikedMenuDTO.swift
//  Siksha
//
//  Created by Codex on 6/24/26.
//

import Foundation

struct MyLikedMenuResponseDTO: Decodable, Sendable {
    let groups: [RestaurantLikedMenuGroupDTO]

    enum CodingKeys: String, CodingKey {
        case groups = "result"
    }
}

struct RestaurantLikedMenuGroupDTO: Decodable, Sendable {
    let id: Int
    let name: String
    let menus: [MyLikedMenuDTO]

    enum CodingKeys: String, CodingKey {
        case id
        case name = "name_kr"
        case menus
    }
}

struct MyLikedMenuDTO: Decodable, Sendable {
    let id: Int
    let code: String
    let nameKr: String
    let nameEn: String?
    let price: Int?
    let score: Double?
    let reviewCount: Int
    let isLiked: Bool
    let likeCount: Int
    let etc: [String]
    let alarm: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case code
        case nameKr = "name_kr"
        case nameEn = "name_en"
        case price
        case score
        case reviewCount = "review_cnt"
        case isLiked = "is_liked"
        case likeCount = "like_cnt"
        case etc
        case alarm
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(Int.self, forKey: .id)
        code = try container.decodeIfPresent(String.self, forKey: .code) ?? ""
        nameKr = try container.decodeIfPresent(String.self, forKey: .nameKr) ?? ""
        nameEn = try container.decodeIfPresent(String.self, forKey: .nameEn)
        price = try container.decodeIfPresent(Int.self, forKey: .price)
        score = try container.decodeIfPresent(Double.self, forKey: .score)
        reviewCount = try container.decodeIfPresent(Int.self, forKey: .reviewCount) ?? 0
        isLiked = try container.decodeIfPresent(Bool.self, forKey: .isLiked) ?? false
        likeCount = try container.decodeIfPresent(Int.self, forKey: .likeCount) ?? 0
        etc = try container.decodeIfPresent([String].self, forKey: .etc) ?? []
        alarm = try container.decodeIfPresent(Bool.self, forKey: .alarm) ?? false
    }
}

struct AlarmMenuDTO: Decodable {
    let id: Int
    let nameKr: String
    let nameEn: String?
    let price: Int?
    let isLiked: Bool
    let etc: [String]
    let alarm: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case nameKr = "name_kr"
        case nameEn = "name_en"
        case price
        case isLiked = "is_liked"
        case etc
        case alarm
    }
}

struct AlarmTimeResponseDTO: Decodable, Sendable {
    let alarmType: String

    enum CodingKeys: String, CodingKey {
        case alarmType = "alarm_type"
    }
}
