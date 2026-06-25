//
//  FetchMealImageReviewsUseCase.swift
//  Siksha
//
//  Created by Codex on 6/26/26.
//

protocol FetchMealImageReviewsUseCase {
    func execute(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel
}

final class DefaultFetchMealImageReviewsUseCase: FetchMealImageReviewsUseCase {
    private let repository: MealReviewRepositoryProtocol
    
    init(repository: MealReviewRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel {
        try await repository.fetchImageReviews(menuId: menuId, page: page, perPage: perPage)
    }
}
