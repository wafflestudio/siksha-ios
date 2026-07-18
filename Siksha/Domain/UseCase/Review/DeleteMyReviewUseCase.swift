//
//  DeleteMyReviewUseCase.swift
//  Siksha
//
//  Created by Codex on 6/26/26.
//

protocol DeleteMyReviewUseCase {
    func execute(reviewId: Int) async throws
}

final class DefaultDeleteMyReviewUseCase: DeleteMyReviewUseCase {
    private let repository: MyReviewRepositoryProtocol

    init(repository: MyReviewRepositoryProtocol) {
        self.repository = repository
    }

    func execute(reviewId: Int) async throws {
        try await repository.deleteMyReview(reviewId: reviewId)
    }
}
