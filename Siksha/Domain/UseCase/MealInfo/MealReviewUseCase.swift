//
//  MealReviewUseCase.swift
//  Siksha
//
//  Created by Codex on 6/7/26.
//

protocol MealReviewUseCase {
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

final class DefaultMealReviewUseCase: MealReviewUseCase {
    private let repository: MealReviewRepositoryProtocol
    
    init(repository: MealReviewRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel {
        try await repository.fetchReviews(menuId: menuId, page: page, perPage: perPage)
    }
    
    func fetchImageReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel {
        try await repository.fetchImageReviews(menuId: menuId, page: page, perPage: perPage)
    }
    
    func fetchScoreDistribution(menuId: Int) async throws -> [Int] {
        try await repository.fetchScoreDistribution(menuId: menuId)
    }
    
    func fetchKeywordDistribution(menuId: Int) async throws -> KeywordDistributionModel {
        try await repository.fetchKeywordDistribution(menuId: menuId)
    }
    
    func fetchCommentRecommendation(score: Int) async throws -> String {
        try await repository.fetchCommentRecommendation(score: score)
    }
    
    func submitReview(_ submission: MealReviewSubmissionModel) async throws {
        try await repository.submitReview(submission)
    }
    
    func editReview(reviewId: Int, submission: MealReviewSubmissionModel) async throws {
        try await repository.editReview(reviewId: reviewId, submission: submission)
    }
    
    func likeReview(reviewId: Int) async throws {
        try await repository.likeReview(reviewId: reviewId)
    }
    
    func unlikeReview(reviewId: Int) async throws {
        try await repository.unlikeReview(reviewId: reviewId)
    }
}
