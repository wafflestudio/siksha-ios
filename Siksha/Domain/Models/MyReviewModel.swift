//
//  MyReviewModel.swift
//  Siksha
//
//  Created by Codex on 6/23/26.
//

import Foundation

struct MyReviewPageModel {
    let totalCount: Int
    let hasNext: Bool
    let restaurants: [MyReviewRestaurantModel]
}

struct MyReviewRestaurantModel {
    let restaurantId: Int
    let nameKr: String
    let nameEn: String?
    let reviews: [MyReviewModel]
}

struct MyReviewModel {
    let id: Int
    let menuId: Int
    let nameKr: String
    let nameEn: String?
    let userId: Int
    let score: Int
    let comment: String
    let etc: [String: [String]]?
    let createdAt: Date?
    let updatedAt: Date?
    let keywordReviews: [String]
    let isLiked: Bool
}
