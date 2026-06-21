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
    private let mealInfoUseCase: MealInfoUseCase
    private var perPage = 10
    var currentPage: Int = 1
    
    private let mealID: Int
    let imageOnly: Bool
    @Published var reviews: [Review] = []
    @Published var hasMorePages = true
    @Published var getReviewStatus: NetworkStatus = .idle
    
    init(
        mealID: Int,
        imageOnly: Bool = false,
        mealInfoUseCase: MealInfoUseCase = DefaultMealInfoUseCase(
            repository: MealInfoRepositoryImpl()
        )
    ) {
        self.mealID = mealID
        self.imageOnly = imageOnly
        self.mealInfoUseCase = mealInfoUseCase
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

        Task { [weak self] in
            guard let self else { return }
            
            do {
                let response = try await mealInfoUseCase.fetchReviews(menuId: mealID, page: currentPage, perPage: perPage)
                await MainActor.run {
                    self.hasMorePages = (self.currentPage < (response.totalCount + self.perPage - 1) / self.perPage)
                    self.currentPage += 1
                    self.getReviewStatus = .succeeded
                    self.reviews += response.reviews
                }
            } catch {
                await MainActor.run {
                    self.getReviewStatus = .failed
                }
            }
        }
    }
    
    private func loadMoreImageReviews() {
        guard getReviewStatus != .loading else {
            return
        }
        
        getReviewStatus = .loading
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let response = try await mealInfoUseCase.fetchImageReviews(menuId: mealID, page: currentPage, perPage: perPage)
                await MainActor.run {
                    self.hasMorePages = response.hasNext
                    self.currentPage += 1
                    self.getReviewStatus = .succeeded
                    self.reviews += response.reviews
                }
            } catch {
                await MainActor.run {
                    self.getReviewStatus = .failed
                }
            }
        }
    }
    
}
