//
//  MealInfoUseCase.swift
//  Siksha
//
//  Created by Codex on 6/7/26.
//

protocol MealInfoUseCase {
    func fetchMenu(menuId: Int) async throws -> MenuModel
    func toggleMenuLike(menu: MenuModel) async throws -> MenuModel
    func fetchReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel
    func fetchReviewImages(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel
    func fetchScoreDistribution(menuId: Int) async throws -> [Int]
    func fetchKeywordDistribution(menuId: Int) async throws -> KeywordDistributionModel
    func toggleReviewLike(review: Review) async throws
    func likeReview(reviewId: Int) async throws
    func unlikeReview(reviewId: Int) async throws
}

final class DefaultMealInfoUseCase: MealInfoUseCase {
    private let repository: MealInfoRepositoryProtocol
    
    init(repository: MealInfoRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchMenu(menuId: Int) async throws -> MenuModel {
        try await repository.fetchMenu(menuId: menuId)
    }
    
    func toggleMenuLike(menu: MenuModel) async throws -> MenuModel {
        if menu.isLiked {
            return try await repository.unlikeMenu(menuId: menu.id)
        }
        return try await repository.likeMenu(menuId: menu.id)
    }
    
    func fetchReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel {
        try await repository.fetchReviews(menuId: menuId, page: page, perPage: perPage)
    }
    
    func fetchReviewImages(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel {
        try await repository.fetchReviewImages(menuId: menuId, page: page, perPage: perPage)
    }
    
    func fetchScoreDistribution(menuId: Int) async throws -> [Int] {
        try await repository.fetchScoreDistribution(menuId: menuId)
    }
    
    func fetchKeywordDistribution(menuId: Int) async throws -> KeywordDistributionModel {
        try await repository.fetchKeywordDistribution(menuId: menuId)
    }
    
    func toggleReviewLike(review: Review) async throws {
        if review.isLiked {
            try await repository.unlikeReview(reviewId: review.id)
        } else {
            try await repository.likeReview(reviewId: review.id)
        }
    }
    
    func likeReview(reviewId: Int) async throws {
        try await repository.likeReview(reviewId: reviewId)
    }
    
    func unlikeReview(reviewId: Int) async throws {
        try await repository.unlikeReview(reviewId: reviewId)
    }
}
