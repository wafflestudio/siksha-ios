//
//  SubmitMealReviewUseCase.swift
//  Siksha
//
//  Created by Codex on 6/26/26.
//

protocol SubmitMealReviewUseCase {
    func execute(_ submission: MealReviewSubmissionModel) async throws
}

final class DefaultSubmitMealReviewUseCase: SubmitMealReviewUseCase {
    private let repository: MealReviewRepositoryProtocol
    
    init(repository: MealReviewRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(_ submission: MealReviewSubmissionModel) async throws {
        try await repository.submitReview(submission)
    }
}
