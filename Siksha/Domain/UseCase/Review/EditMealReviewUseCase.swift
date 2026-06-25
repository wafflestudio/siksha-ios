//
//  EditMealReviewUseCase.swift
//  Siksha
//
//  Created by Codex on 6/26/26.
//

protocol EditMealReviewUseCase {
    func execute(reviewId: Int, submission: MealReviewSubmissionModel) async throws
}

final class DefaultEditMealReviewUseCase: EditMealReviewUseCase {
    private let repository: MealReviewRepositoryProtocol
    
    init(repository: MealReviewRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(reviewId: Int, submission: MealReviewSubmissionModel) async throws {
        try await repository.editReview(reviewId: reviewId, submission: submission)
    }
}
