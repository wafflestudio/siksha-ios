//
//  Review.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import UIKit

struct Review: Codable {
    var id: Int
    var mealId: Int
    var userId: Int
    var score: Double
    var comment: String?
    var images: [String: [String]]?
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case mealId = "menu_id"
        case userId = "user_id"
        case score = "score"
        case comment = "comment"
        case images = "etc"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct RenewalReviewRestaurant: Codable, Identifiable {
    let restaurantId: Int
    let nameKr: String
    let nameEn: String?
    let reviews: [RenewalReview]
    
    var id: Int { restaurantId }
    
    enum CodingKeys: String, CodingKey {
        case restaurantId = "restaurant_id"
        case nameKr = "name_kr"
        case nameEn = "name_en"
        case reviews
    }
}

struct RenewalReview: Codable, Identifiable {
    let id: Int
    let menuId: Int
    let nameKr: String
    let nameEn: String?
    let userId: Int
    let score: Int
    let comment: String
    let etc: String?
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
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: createdAt)
    }
    
    var updatedDate: Date? {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: updatedAt)
    }
}
