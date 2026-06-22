//
//  Review.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation

struct Review: Hashable {
    let id: Int
    let menuId: Int
    let userId: Int
    let score: Double
    let comment: String?
    let etc: [String: [String]]?
    let keywordReviews: [String]
    let likeCount: Int
    let isLiked: Bool
    let createdAt: Date
    let updatedAt: Date
}

struct MyReviewRestaurant: Codable, Identifiable {
    let restaurantId: Int
    let nameKr: String
    let nameEn: String?
    let reviews: [MyReview]
    
    var id: Int { restaurantId }
    
    enum CodingKeys: String, CodingKey {
        case restaurantId = "restaurant_id"
        case nameKr = "name_kr"
        case nameEn = "name_en"
        case reviews
    }
}

struct MyReview: Codable, Identifiable {
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
    
    var createdDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: createdAt)
    }
    
    var updatedDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.date(from: updatedAt)
    }
}
