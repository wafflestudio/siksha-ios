//
//  MealReviewRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 6/23/26.
//

import Foundation

protocol MealReviewRepositoryProtocol {
    func fetchReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel
    func fetchImageReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel
    func fetchScoreDistribution(menuId: Int) async throws -> [Int]
    func fetchKeywordDistribution(menuId: Int) async throws -> KeywordDistributionModel
    func fetchCommentRecommendation(score: Int) async throws -> String
    func submitReview(_ submission: MealReviewSubmissionModel) async throws
    func editReview(reviewId: Int, submission: MealReviewSubmissionModel) async throws
    func likeReview(reviewId: Int) async throws
    func unlikeReview(reviewId: Int) async throws
}
