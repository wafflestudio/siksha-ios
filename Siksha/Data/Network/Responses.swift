//
//  Responses.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/11.
//

import Foundation

struct CommentRecommendationResponse: Codable, Sendable {
    var comment: String
}

struct UserInfoResponse: Codable {
    var id: Int
    var type: String
    var identity: String
    var etc: String?
}

struct ScoreDistributionResponse: Codable, Sendable {
    var dist: [Int]
}

struct MenuIdResponse: Codable, Sendable {
    let createdAt: String
    let updatedAt: String
    let id: Int
    let restaurantId: Int
    let code: String
    let date: String
    let type: String
    let nameKr: String?
    let nameEn: String?
    let price: Int?
    let etc: [String]
    let score: Double?
    let reviewCnt: Int
    let isLiked: Bool
    let likeCnt: Int

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case restaurantId = "restaurant_id"
        case nameKr = "name_kr"
        case nameEn = "name_en"
        case reviewCnt = "review_cnt"
        case isLiked = "is_liked"
        case likeCnt = "like_cnt"
        case id, code, date, type, price, etc, score
    }
}

struct FestivalDatesResponse: Codable {
    var festivalDates: [String]

    enum CodingKeys: String, CodingKey {
        case festivalDates = "festival_dates"
    }
}
struct KeywordDistributionResponse: Codable, Sendable {
    let tasteKeyword: String
    let tasteCnt: Int
    let tasteTotal: Int

    let priceKeyword: String
    let priceCnt: Int
    let priceTotal: Int

    let foodCompositionKeyword: String
    let foodCompositionCnt: Int
    let foodCompositionTotal: Int
}
