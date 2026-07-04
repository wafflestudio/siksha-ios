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
