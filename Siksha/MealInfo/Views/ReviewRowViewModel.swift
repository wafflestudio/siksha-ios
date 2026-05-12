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
    
    init(review: Review, showImage: Bool) {
        self.review = review
        self.showImage = showImage
        self.likeCount = review.likeCount
        self.isLiked = review.isLiked
    }
    
    private var getLikeStatus: NetworkStatus = .idle
    
    private func likeReview() {
        Networking.shared.likeReview(reviewId: review.id)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isLiked = true
                    self?.likeCount += 1
                    self?.getLikeStatus = .succeeded
                case .failure(let error):
                    self?.getLikeStatus = .failed
                    self?.error = error
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
    }
    
    private func unlikeReview() {
        Networking.shared.unlikeReview(reviewId: review.id)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    self?.isLiked = false
                    self?.likeCount -= 1
                    self?.getLikeStatus = .succeeded
                case .failure(let error):
                    self?.getLikeStatus = .failed
                    self?.error = error
                }
            } receiveValue: { _ in }
            .store(in: &cancellables)
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
