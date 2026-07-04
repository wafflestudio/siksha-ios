//
//  MyReviewRemoteDataSource.swift
//  Siksha
//
//  Created by Codex on 6/23/26.
//

import Alamofire
import Foundation

protocol MyReviewRemoteDataSource {
    func fetchMyReviews(page: Int, perPage: Int) async throws -> MyReviewPageResponseDTO
    func deleteMyReview(reviewId: Int) async throws
}

final class MyReviewRemoteDataSourceImpl: MyReviewRemoteDataSource {
    func fetchMyReviews(page: Int, perPage: Int) async throws -> MyReviewPageResponseDTO {
        try await AF
            .request(SikshaAPI.getMyReview(page: page, perPage: perPage))
            .validate()
            .serializingDecodable(MyReviewPageResponseDTO.self)
            .value
    }
    
    func deleteMyReview(reviewId: Int) async throws {
        _ = try await AF
            .request(SikshaAPI.deleteMyReview(reviewId: reviewId))
            .validate()
            .serializingData(emptyResponseCodes: [200, 201, 204])
            .value
    }
}
