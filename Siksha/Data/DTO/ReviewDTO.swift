//
//  ReviewDTO.swift
//  Siksha
//
//  Created by Codex on 6/22/26.
//

import Foundation

struct ReviewPageResponseDTO: Decodable, Sendable {
    let totalCount: Int
    let hasNext: Bool
    let result: [ReviewDTO]
}

struct ReviewDTO: Decodable, Sendable {
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

extension ReviewDTO {
    func toDomain() -> Review {
        Review(
            id: id,
            menuId: menuId,
            userId: userId,
            score: score,
            comment: comment,
            etc: etc,
            keywordReviews: keywordReviews,
            likeCount: likeCount,
            isLiked: isLiked,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
