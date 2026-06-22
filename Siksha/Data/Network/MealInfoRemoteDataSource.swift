//
//  MealInfoRemoteDataSource.swift
//  Siksha
//
//  Created by Codex on 6/7/26.
//

import Alamofire
import Foundation

protocol MealInfoRemoteDataSource {
    func fetchMenu(menuId: Int) async throws -> MenuIdResponse
    func likeMenu(menuId: Int) async throws -> MenuIdResponse
    func unlikeMenu(menuId: Int) async throws -> MenuIdResponse
    func fetchReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageResponseDTO
    func fetchImageReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageResponseDTO
    func fetchScoreDistribution(menuId: Int) async throws -> ScoreDistributionResponse
    func fetchKeywordDistribution(menuId: Int) async throws -> KeywordDistributionResponse
    func fetchCommentRecommendation(score: Int) async throws -> CommentRecommendationResponse
    func submitReview(_ submission: MealReviewSubmissionModel) async throws
    func submitReviewImages(_ submission: MealReviewSubmissionModel) async throws
    func editReview(reviewId: Int, submission: MealReviewSubmissionModel) async throws
    func likeReview(reviewId: Int) async throws
    func unlikeReview(reviewId: Int) async throws
}

final class MealInfoRemoteDataSourceImpl: MealInfoRemoteDataSource {
    func fetchMenu(menuId: Int) async throws -> MenuIdResponse {
        try await AF
            .request(SikshaAPI.getMenuFromId(menuId: menuId))
            .validate()
            .serializingDecodable(MenuIdResponse.self, decoder: JSONDecoder())
            .value
    }
    
    func likeMenu(menuId: Int) async throws -> MenuIdResponse {
        try await AF
            .request(SikshaAPI.likeMenu(menuId: menuId))
            .validate()
            .serializingDecodable(MenuIdResponse.self, decoder: JSONDecoder())
            .value
    }
    
    func unlikeMenu(menuId: Int) async throws -> MenuIdResponse {
        try await AF
            .request(SikshaAPI.unlikeMenu(menuId: menuId))
            .validate()
            .serializingDecodable(MenuIdResponse.self, decoder: JSONDecoder())
            .value
    }
    
    func fetchReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageResponseDTO {
        try await AF
            .request(SikshaAPI.getReviews(menuId: menuId, page: page, perPage: perPage))
            .validate()
            .serializingDecodable(ReviewPageResponseDTO.self, decoder: reviewDecoder())
            .value
    }
    
    func fetchImageReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageResponseDTO {
        try await AF
            .request(SikshaAPI.getImageReviews(menuId: menuId, page: page, perPage: perPage))
            .validate()
            .serializingDecodable(ReviewPageResponseDTO.self, decoder: reviewDecoder())
            .value
    }
    
    func fetchScoreDistribution(menuId: Int) async throws -> ScoreDistributionResponse {
        try await AF
            .request(SikshaAPI.getScoreDistribution(menuId: menuId))
            .validate()
            .serializingDecodable(ScoreDistributionResponse.self, decoder: JSONDecoder())
            .value
    }
    
    func fetchKeywordDistribution(menuId: Int) async throws -> KeywordDistributionResponse {
        try await AF
            .request(SikshaAPI.getKeywordDistribution(menuId: menuId))
            .validate()
            .serializingDecodable(KeywordDistributionResponse.self, decoder: NetworkDecoder.make())
            .value
    }
    
    func fetchCommentRecommendation(score: Int) async throws -> CommentRecommendationResponse {
        try await AF
            .request(SikshaAPI.getCommentRecommendation(score: score))
            .validate()
            .serializingDecodable(CommentRecommendationResponse.self, decoder: JSONDecoder())
            .value
    }
    
    func submitReview(_ submission: MealReviewSubmissionModel) async throws {
        let endpoint = SikshaAPI.submitReview(
            menuId: submission.menuId,
            score: submission.score,
            comment: submission.comment,
            taste: submission.taste,
            price: submission.price,
            foodComposition: submission.foodComposition
        )
        
        try await validateNoContentRequest(AF.request(endpoint))
    }
    
    func editReview(reviewId: Int, submission: MealReviewSubmissionModel) async throws {
        let endpoint = SikshaAPI.editReview(
            reviewId: reviewId,
            menuId: submission.menuId,
            score: submission.score,
            comment: submission.comment,
            taste: submission.taste,
            price: submission.price,
            foodComposition: submission.foodComposition,
            images: submission.images
        )
        
        try await validateNoContentRequest(AF.upload(multipartFormData: endpoint.multipartFormData!, with: endpoint))
    }
    
    func likeReview(reviewId: Int) async throws {
        try await validateNoContentRequest(AF.request(SikshaAPI.likeReview(reviewId: reviewId)))
    }
    
    func unlikeReview(reviewId: Int) async throws {
        try await validateNoContentRequest(AF.request(SikshaAPI.unlikeReview(reviewId: reviewId)))
    }
    
    func submitReviewImages(_ submission: MealReviewSubmissionModel) async throws {
        let endpoint = SikshaAPI.submitReviewImages(
            menuId: submission.menuId,
            score: submission.score,
            comment: submission.comment,
            taste: submission.taste,
            price: submission.price,
            foodComposition: submission.foodComposition,
            images: submission.images ?? []
        )
        
        try await validateNoContentRequest(AF.upload(multipartFormData: endpoint.multipartFormData!, with: endpoint))
    }
    
    private func validateNoContentRequest(_ request: DataRequest) async throws {
        let response = await request
            .validate()
            .serializingData()
            .response
        
        if let statusCode = response.response?.statusCode,
           200..<300 ~= statusCode {
            return
        }
        
        if let statusCode = response.response?.statusCode {
            throw MealReviewSubmissionError.statusCode(statusCode)
        }
        
        if let error = response.error {
            throw MealReviewSubmissionError.underlying(error)
        }
        
        throw MealReviewSubmissionError.statusCode(0)
    }
    
    private func reviewDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return decoder
    }
}
