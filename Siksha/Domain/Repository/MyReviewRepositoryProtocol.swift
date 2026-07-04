//
//  MyReviewRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 6/23/26.
//

import Foundation

protocol MyReviewRepositoryProtocol {
    func fetchMyReviews(page: Int, perPage: Int) async throws -> MyReviewPageModel
    func deleteMyReview(reviewId: Int) async throws
}
