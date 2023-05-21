//
//  Responses.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/11.
//

import Foundation

struct ReviewResponse: Codable {
    var totalCount: Int
    var reviews: [Review]
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total_count"
        case reviews = "result"
    }
}

struct CommentRecommendationResponse: Codable {
    var comment: String
}

struct UserInfoResponse: Codable {
    var id: Int
    var type: String
    var identity: String
    var etc: String?
}

struct ScoreDistributionResponse: Codable {
    var dist: [Int]
}
struct MenuIdResponse:Codable{
    var is_liked:Bool
}
