//
//  FetchMyReviewsUseCase.swift
//  Siksha
//
//  Created by Codex on 6/26/26.
//

protocol FetchMyReviewsUseCase {
    func execute(page: Int, perPage: Int) async throws -> MyReviewPageModel
}

final class DefaultFetchMyReviewsUseCase: FetchMyReviewsUseCase {
    private let repository: MyReviewRepositoryProtocol
    
    init(repository: MyReviewRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(page: Int, perPage: Int) async throws -> MyReviewPageModel {
        try await repository.fetchMyReviews(page: page, perPage: perPage)
    }
}
