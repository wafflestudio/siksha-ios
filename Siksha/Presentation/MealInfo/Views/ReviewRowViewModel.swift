//
//  ReviewRowViewModel.swift
//  Siksha
//
//  Created by Jihyeon on 10/29/25.
//

import Foundation
import Combine

class ReviewRowViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let mealInfoUseCase: MealInfoUseCase
    
    private let review: Review
    let showImage: Bool
    
    var imageUrlString: [String] {
        review.etc?["images"] ?? []
    }
    
    var score: Double {
        review.score
    }
    
    var comment: String {
        review.comment ?? ""
    }
    
    var hasComment: Bool {
        !comment.isEmpty
    }
    
    var legibleDate: String {
        review.createdAt.toLegibleString()
    }
    
    var nickname: String {
        "ID \(review.userId)"
    }
    
    var hasKeywords: Bool {
        !keywords.isEmpty
    }
    
    var keywords: [String] {
        review.keywordReviews.filter{ !$0.isEmpty }
    }

    @Published var likeCount: Int
    @Published var isLiked: Bool
    @Published var isImageExpanded: Bool = false
    @Published var tappedIndex: Int = 0
    @Published var error: AppError?
    
    init(
        review: Review,
        showImage: Bool,
        mealInfoUseCase: MealInfoUseCase = DefaultMealInfoUseCase(
            repository: MealInfoRepositoryImpl()
        )
    ) {
        self.review = review
        self.showImage = showImage
        self.mealInfoUseCase = mealInfoUseCase
        self.likeCount = review.likeCount
        self.isLiked = review.isLiked
    }
    
    private var getLikeStatus: NetworkStatus = .idle
    
    private func likeReview() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                try await mealInfoUseCase.likeReview(reviewId: review.id)
                await MainActor.run {
                    self.isLiked = true
                    self.likeCount += 1
                    self.getLikeStatus = .succeeded
                }
            } catch {
                await MainActor.run {
                    self.getLikeStatus = .failed
                    self.error = ErrorHelper.categorize(error)
                }
            }
        }
    }
    
    private func unlikeReview() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                try await mealInfoUseCase.unlikeReview(reviewId: review.id)
                await MainActor.run {
                    self.isLiked = false
                    self.likeCount = max(0, self.likeCount - 1)
                    self.getLikeStatus = .succeeded
                }
            } catch {
                await MainActor.run {
                    self.getLikeStatus = .failed
                    self.error = ErrorHelper.categorize(error)
                }
            }
        }
    }
    
    func toggleLike(){
        guard getLikeStatus != .loading else{
            return
        }
        
        getLikeStatus = .loading
        if isLiked {
            unlikeReview()
        } else {
            likeReview()
        }
    }
}
