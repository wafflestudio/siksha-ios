//
//  FetchMealReviewScoreDistributionUseCase.swift
//  Siksha
//
//  Created by Codex on 6/26/26.
//

protocol FetchMealReviewScoreDistributionUseCase {
    func execute(menuId: Int) async throws -> [Int]
}

final class DefaultFetchMealReviewScoreDistributionUseCase: FetchMealReviewScoreDistributionUseCase {
    private let repository: MealReviewRepositoryProtocol

    init(repository: MealReviewRepositoryProtocol) {
        self.repository = repository
    }

    func execute(menuId: Int) async throws -> [Int] {
        try await repository.fetchScoreDistribution(menuId: menuId)
    }
}
