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
    
    private let mealID: Int
    let imageOnly: Bool
    @Published var reviews: [Review] = []
    @Published var hasMorePages = true
    @Published var getReviewStatus: NetworkStatus = .idle
    
    init(mealID: Int, imageOnly: Bool = false) {
        self.mealID = mealID
        self.imageOnly = imageOnly
    }
    
    func loadMoreReviewsIfNeeded(current: Review? = nil) {
        if reviews.isEmpty && getReviewStatus != .loading {
            if imageOnly {
                loadMoreImageReviews()
            } else {
                loadMoreReviews()
            }
            return
        }
        
        let thresholdIndex = reviews.index(
            reviews.endIndex,
            offsetBy: -3,
            limitedBy: reviews.startIndex
        ) ?? reviews.startIndex
        
        guard hasMorePages,
              let currentIndex = reviews.firstIndex(where: { $0.id == current?.id })
        else { return }
        
        // 끝에서 3개 이내로 왔을 때 로드
        if currentIndex == thresholdIndex {
            if imageOnly {
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

        Networking.shared.getReviews(menuId: mealID, page: currentPage, perPage: perPage)
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
            .map(\.?.result)
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
        
        Networking.shared.getReviewImages(menuId: mealID, page: currentPage, perPage: perPage)
            .map(\.value)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self else { return }
                guard let response = response else {
                    self.getReviewStatus = .failed
                    return
                }
                self.hasMorePages = response.hasNext
                self.currentPage += 1
                self.getReviewStatus = .succeeded
            })
            .map(\.?.result)
            .replaceNil(with: [])
            .map { self.reviews + $0 }
            .assign(to: \.reviews, on: self)
            .store(in: &cancellables)
    }
    
}
