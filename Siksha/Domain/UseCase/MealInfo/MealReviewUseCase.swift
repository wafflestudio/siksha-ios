//
//  MealReviewUseCase.swift
//  Siksha
//
//  Created by Codex on 6/7/26.
//

protocol MealReviewUseCase {
    func fetchCommentRecommendation(score: Int) async throws -> String
    func submitReview(_ submission: MealReviewSubmissionModel) async throws
    func editReview(reviewId: Int, submission: MealReviewSubmissionModel) async throws
}

final class DefaultMealReviewUseCase: MealReviewUseCase {
    private let repository: MealInfoRepositoryProtocol
    
    init(repository: MealInfoRepositoryProtocol) {
        self.repository = repository
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
}
