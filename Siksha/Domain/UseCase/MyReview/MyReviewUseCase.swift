//
//  MyReviewUseCase.swift
//  Siksha
//
//  Created by Codex on 6/23/26.
//

import Foundation

protocol MyReviewUseCase {
    func fetchMyReviews(page: Int, perPage: Int) async throws -> MyReviewPageModel
    func deleteMyReview(reviewId: Int) async throws
}

final class DefaultMyReviewUseCase: MyReviewUseCase {
    private let repository: MyReviewRepositoryProtocol
    
    init(repository: MyReviewRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchMyReviews(page: Int, perPage: Int) async throws -> MyReviewPageModel {
        try await repository.fetchMyReviews(page: page, perPage: perPage)
    }
    
    func deleteMyReview(reviewId: Int) async throws {
        try await repository.deleteMyReview(reviewId: reviewId)
    }
}
