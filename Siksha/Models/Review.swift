//
//  Review.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import Foundation
import UIKit

struct Review: Codable, Hashable {
    var id: Int
    var menuId: Int
    var userId: Int
    var score: Double
    var comment: String?
    var etc: [String: [String]]?
    var keywordReviews: [String]
    var likeCount: Int
    var isLiked: Bool
    var createdAt: Date
    var updatedAt: Date
}

