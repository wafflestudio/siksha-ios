//
//  FetchReviewCommentRecommendationUseCase.swift
//  Siksha
//
//  Created by Codex on 6/26/26.
//

protocol FetchReviewCommentRecommendationUseCase {
    func execute(score: Int) async throws -> String
}

final class DefaultFetchReviewCommentRecommendationUseCase: FetchReviewCommentRecommendationUseCase {
    private let repository: MealReviewRepositoryProtocol

    init(repository: MealReviewRepositoryProtocol) {
        self.repository = repository
    }

    func execute(score: Int) async throws -> String {
        try await repository.fetchCommentRecommendation(score: score)
    }
}
