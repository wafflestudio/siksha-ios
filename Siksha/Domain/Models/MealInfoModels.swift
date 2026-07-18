//
//  MealInfoModels.swift
//  Siksha
//
//  Created by Codex on 6/7/26.
//

import Foundation

struct ReviewPageModel: Sendable {
    let totalCount: Int
    let hasNext: Bool
    let reviews: [Review]
}

struct KeywordDistributionModel: Sendable {
    let tasteKeyword: String
    let tasteCount: Int
    let tasteTotal: Int
    let priceKeyword: String
    let priceCount: Int
    let priceTotal: Int
    let foodCompositionKeyword: String
    let foodCompositionCount: Int
    let foodCompositionTotal: Int
}

struct MealReviewSubmissionModel: Sendable {
    let menuId: Int
    let score: Int
    let comment: String
    let taste: String
    let price: String
    let foodComposition: String
    let images: [Data]?
}

enum MealReviewSubmissionError: Error {
    case statusCode(Int)
    case underlying(Error)
}
