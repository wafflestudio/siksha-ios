//
//  MealInfoRepositoryImpl.swift
//  Siksha
//
//  Created by Codex on 6/7/26.
//

import Foundation

final class MealInfoRepositoryImpl: MealInfoRepositoryProtocol {
    private let remote: MealInfoRemoteDataSource
    
    init(remote: MealInfoRemoteDataSource = MealInfoRemoteDataSourceImpl()) {
        self.remote = remote
    }
    
    func fetchMenu(menuId: Int) async throws -> MenuModel {
        try await remote.fetchMenu(menuId: menuId).toDomain()
    }
    
    func likeMenu(menuId: Int) async throws -> MenuModel {
        try await remote.likeMenu(menuId: menuId).toDomain()
    }
    
    func unlikeMenu(menuId: Int) async throws -> MenuModel {
        try await remote.unlikeMenu(menuId: menuId).toDomain()
    }
    
    func fetchReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel {
        try await remote.fetchReviews(menuId: menuId, page: page, perPage: perPage).toDomain()
    }
    
    func fetchImageReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel {
        try await remote.fetchImageReviews(menuId: menuId, page: page, perPage: perPage).toDomain()
    }
    
    func fetchScoreDistribution(menuId: Int) async throws -> [Int] {
        try await remote.fetchScoreDistribution(menuId: menuId).dist
    }
    
    func fetchKeywordDistribution(menuId: Int) async throws -> KeywordDistributionModel {
        try await remote.fetchKeywordDistribution(menuId: menuId).toDomain()
    }
    
    func fetchCommentRecommendation(score: Int) async throws -> String {
        try await remote.fetchCommentRecommendation(score: score).comment
    }
    
    func submitReview(_ submission: MealReviewSubmissionModel) async throws {
        if submission.images?.isEmpty == false {
            try await remote.submitReviewImages(submission)
        } else {
            try await remote.submitReview(submission)
        }
    }
    
    func editReview(reviewId: Int, submission: MealReviewSubmissionModel) async throws {
        try await remote.editReview(reviewId: reviewId, submission: submission)
    }
    
    func likeReview(reviewId: Int) async throws {
        try await remote.likeReview(reviewId: reviewId)
    }
    
    func unlikeReview(reviewId: Int) async throws {
        try await remote.unlikeReview(reviewId: reviewId)
    }
}

private extension MenuIdResponse {
    func toDomain() -> MenuModel {
        MenuModel(
            id: id,
            code: code,
            nameKr: nameKr ?? "",
            nameEn: nameEn ?? "",
            price: price ?? 0,
            score: score ?? 0,
            reviewCount: reviewCnt,
            isLiked: isLiked,
            likeCount: likeCnt,
            imageURLStrings: etc
        )
    }
}

private extension ReviewPageResponseDTO {
    func toDomain() -> ReviewPageModel {
        ReviewPageModel(
            totalCount: totalCount,
            hasNext: hasNext,
            reviews: result.map { $0.toDomain() }
        )
    }
}

private extension KeywordDistributionResponse {
    func toDomain() -> KeywordDistributionModel {
        KeywordDistributionModel(
            tasteKeyword: tasteKeyword,
            tasteCount: tasteCnt,
            tasteTotal: tasteTotal,
            priceKeyword: priceKeyword,
            priceCount: priceCnt,
            priceTotal: priceTotal,
            foodCompositionKeyword: foodCompositionKeyword,
            foodCompositionCount: foodCompositionCnt,
            foodCompositionTotal: foodCompositionTotal
        )
    }
}
