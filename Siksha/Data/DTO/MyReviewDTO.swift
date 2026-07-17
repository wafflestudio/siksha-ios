//
//  MyReviewDTO.swift
//  Siksha
//
//  Created by Codex on 6/23/26.
//

import Foundation

struct MyReviewPageResponseDTO: Decodable {
    let totalCount: Int
    let hasNext: Bool
    let result: [MyReviewRestaurantDTO]

    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case hasNext = "has_next"
        case result
    }
}

struct MyReviewRestaurantDTO: Decodable {
    let restaurantId: Int
    let nameKr: String
    let nameEn: String?
    let reviews: [MyReviewDTO]

    enum CodingKeys: String, CodingKey {
        case restaurantId = "restaurant_id"
        case nameKr = "name_kr"
        case nameEn = "name_en"
        case reviews
    }
}

struct MyReviewDTO: Decodable {
    let id: Int
    let menuId: Int
    let nameKr: String
    let nameEn: String?
    let userId: Int
    let score: Int
    let comment: String
    let etc: [String: [String]]?
    let createdAt: String
    let updatedAt: String
    let keywordReviews: [String?]
    let isLiked: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case menuId = "menu_id"
        case nameKr = "name_kr"
        case nameEn = "name_en"
        case userId = "user_id"
        case score
        case comment
        case etc
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case keywordReviews = "keyword_reviews"
        case isLiked = "is_liked"
    }
}

extension MyReviewPageResponseDTO {
    func toDomain() -> MyReviewPageModel {
        MyReviewPageModel(
            totalCount: totalCount,
            hasNext: hasNext,
            restaurants: result.map { $0.toDomain() }
        )
    }
}

private extension MyReviewRestaurantDTO {
    func toDomain() -> MyReviewRestaurantModel {
        MyReviewRestaurantModel(
            restaurantId: restaurantId,
            nameKr: nameKr,
            nameEn: nameEn,
            reviews: reviews.map { $0.toDomain() }
        )
    }
}

private extension MyReviewDTO {
    func toDomain() -> MyReviewModel {
        MyReviewModel(
            id: id,
            menuId: menuId,
            nameKr: nameKr,
            nameEn: nameEn,
            userId: userId,
            score: score,
            comment: comment,
            etc: etc,
            createdAt: Self.date(from: createdAt),
            updatedAt: Self.date(from: updatedAt),
            keywordReviews: keywordReviews.compactMap { $0 },
            isLiked: isLiked
        )
    }

    static func date(from string: String) -> Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: string)
    }
}
