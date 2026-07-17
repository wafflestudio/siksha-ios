//
//  FetchMealReviewsUseCase.swift
//  Siksha
//
//  Created by Codex on 6/26/26.
//

protocol FetchMealReviewsUseCase {
    func execute(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel
}

final class DefaultFetchMealReviewsUseCase: FetchMealReviewsUseCase {
    private let repository: MealReviewRepositoryProtocol

    init(repository: MealReviewRepositoryProtocol) {
        self.repository = repository
    }

    func execute(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel {
        try await repository.fetchReviews(menuId: menuId, page: page, perPage: perPage)
    }
}
