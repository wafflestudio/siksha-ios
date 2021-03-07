//
//  Review.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation

struct Review: Codable {
    var id: Int
    var mealId: Int
    var userId: Int
    var score: Double
    var comment: String
    var createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case mealId = "menu_id"
        case userId = "user_id"
        case score = "score"
        case comment = "comment"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}

struct ReviewResponse: Codable {
    var totalCount: Int
    var reviews: [Review]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case reviews = "result"
    }
}
