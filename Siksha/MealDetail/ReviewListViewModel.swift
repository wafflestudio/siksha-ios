//
//  ReviewViewModel.swift
//  Siksha
//
//  Created by You Been Lee on 2021/06/05.
//

import Foundation
import Combine
import UIKit

public class ReviewListViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private var perPage = 10
    var currentPage: Int = 1
    
    @Published var meal: Meal!
    @Published var reviews: [Review] = []
    @Published var hasMorePages = true
    @Published var getReviewStatus: NetworkStatus = .idle
    
    func loadMoreReviewsIfNeeded(currentItem item: Review?, _ onlyImage: Bool) {
        guard let item = item else {
            if onlyImage {
                loadMoreImageReviews()
            } else {
                loadMoreReviews()
            }
            return
        }
        
        let thresholdIndex = reviews.index(reviews.endIndex, offsetBy: -3)
        
        if reviews.firstIndex(where: { $0.id == item.id }) == thresholdIndex && hasMorePages {
            if onlyImage {
                loadMoreImageReviews()
            } else {
                loadMoreReviews()
            }
        }
    }
    
    private func loadMoreReviews() {
        guard getReviewStatus != .loading else {
            return
        }
        
        getReviewStatus = .loading

        Networking.shared.getReviews(menuId: meal.id, page: currentPage, perPage: perPage)
            .map(\.value)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self else { return }
                guard let response = response else {
                    self.getReviewStatus = .failed
                    return
                }
                self.hasMorePages = (self.currentPage < (response.totalCount+self.perPage-1)/self.perPage)
                self.currentPage += 1
                self.getReviewStatus = .succeeded
            })
            .map(\.?.reviews)
            .replaceNil(with: [])
            .map { self.reviews + $0 }
            .assign(to: \.reviews, on: self)
            .store(in: &cancellables)
    }
    
    private func loadMoreImageReviews() {
        guard getReviewStatus != .loading else {
            return
        }
        
        getReviewStatus = .loading
        
        Networking.shared.getReviewImages(menuId: meal.id, page: currentPage, perPage: perPage, comment: false, etc: true)
            .map(\.value)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self else { return }
                guard let response = response else {
                    self.getReviewStatus = .failed
                    return
                }
                self.hasMorePages = (self.currentPage < (response.totalCount+self.perPage-1)/self.perPage)
                self.currentPage += 1
                self.getReviewStatus = .succeeded
            })
            .map(\.?.reviews)
            .replaceNil(with: [])
            .map { self.reviews + $0 }
            .assign(to: \.reviews, on: self)
            .store(in: &cancellables)
    }
    
}
