//
//  ReviewViewModel.swift
//  Siksha
//
//  Created by You Been Lee on 2021/06/05.
//

import Foundation
import Combine
import UIKit

public class ReviewViewModel: ObservableObject {
    
    private var cancellables = Set<AnyCancellable>()
    var currentPage: Int = 1
    
    @Published var meal: Meal
    @Published var mealReviews: [Review] = []
    @Published var mealImageReviews: [Review] = []
    @Published var hasMorePages = true
    @Published var getReviewStatus: NetworkStatus = .idle
    
    init(_ meal: Meal) {
        self.meal = meal
    }
    
    func loadMoreReviewsIfNeeded(currentItem item: Review?) {
        guard let item = item else {
            loadMoreReviews()
            return
        }
        
        let thresholdIndex = mealReviews.index(mealReviews.endIndex, offsetBy: -5)
        
        if mealReviews.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            loadMoreReviews()
        }
    }
    
    func loadMoreImageReviewsIfNeeded(currentItem item: Review?) {
        guard let item = item else {
            loadMoreImageReviews()
            return
        }
        
        let thresholdIndex = mealImageReviews.index(mealImageReviews.endIndex, offsetBy: -5)
        
        if mealImageReviews.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            loadMoreImageReviews()
        }
    }
    
    private func loadMoreReviews() {
        guard getReviewStatus != .loading else {
            return
        }
        
        getReviewStatus = .loading

        Networking.shared.getReviews(menuId: meal.id, page: currentPage, perPage: 10)
            .map(\.value)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self else { return }
                guard let response = response else {
                    self.getReviewStatus = .failed
                    return
                }
                self.hasMorePages = (self.currentPage < (response.totalCount+9)/10)
                self.currentPage += 1
                self.getReviewStatus = .succeeded
            })
            .map(\.?.reviews)
            .replaceNil(with: [])
            .map { self.mealReviews + $0 }
            .assign(to: \.mealReviews, on: self)
            .store(in: &cancellables)
    }
    
    private func loadMoreImageReviews() {
        
        Networking.shared.getReviewImages(menuId: meal.id, page: currentPage, perPage: 10, comment: false, etc: true)
            .map(\.value)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self else { return }
                guard let response = response else {
                    self.getReviewStatus = .failed
                    return
                }
                self.hasMorePages = (self.currentPage < (response.totalCount+9)/10)
                self.currentPage += 1
                self.getReviewStatus = .succeeded
            })
            .map(\.?.reviews)
            .replaceNil(with: [])
            .map { self.mealImageReviews + $0 }
            .assign(to: \.mealImageReviews, on: self)
            .store(in: &cancellables)
    }
    
}
