//
//  MyReviewRepositoryImpl.swift
//  Siksha
//
//  Created by Codex on 6/23/26.
//

import Foundation

final class MyReviewRepositoryImpl: MyReviewRepositoryProtocol {
    private let remote: MyReviewRemoteDataSource
    
    init(remote: MyReviewRemoteDataSource = MyReviewRemoteDataSourceImpl()) {
        self.remote = remote
    }
    
    func fetchMyReviews(page: Int, perPage: Int) async throws -> MyReviewPageModel {
        try await remote.fetchMyReviews(page: page, perPage: perPage).toDomain()
    }
    
    func deleteMyReview(reviewId: Int) async throws {
        try await remote.deleteMyReview(reviewId: reviewId)
    }
}
