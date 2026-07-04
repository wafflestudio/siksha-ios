//
//  FetchMealReviewKeywordDistributionUseCase.swift
//  Siksha
//
//  Created by Codex on 6/26/26.
//

protocol FetchMealReviewKeywordDistributionUseCase {
    func execute(menuId: Int) async throws -> KeywordDistributionModel
}

final class DefaultFetchMealReviewKeywordDistributionUseCase: FetchMealReviewKeywordDistributionUseCase {
    private let repository: MealReviewRepositoryProtocol
    
    init(repository: MealReviewRepositoryProtocol) {
        self.repository = repository
    }
    
    func execute(menuId: Int) async throws -> KeywordDistributionModel {
        try await repository.fetchKeywordDistribution(menuId: menuId)
    }
}
