//
//  UpdateReviewLikeUseCase.swift
//  Siksha
//
//  Created by Codex on 6/26/26.
//

protocol UpdateReviewLikeUseCase {
    func execute(reviewId: Int, isLiked: Bool) async throws
}

final class DefaultUpdateReviewLikeUseCase: UpdateReviewLikeUseCase {
    private let repository: MealReviewRepositoryProtocol

    init(repository: MealReviewRepositoryProtocol) {
        self.repository = repository
    }

    func execute(reviewId: Int, isLiked: Bool) async throws {
        if isLiked {
            try await repository.likeReview(reviewId: reviewId)
        } else {
            try await repository.unlikeReview(reviewId: reviewId)
        }
    }
}
