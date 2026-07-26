//
//  ReviewViewModel.swift
//  Siksha
//
//  Created by You Been Lee on 2021/06/05.
//

import Combine
import Foundation
import UIKit

@MainActor
public class ReviewListViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    private let fetchMealReviewsUseCase: FetchMealReviewsUseCase
    private let fetchMealImageReviewsUseCase: FetchMealImageReviewsUseCase
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
        fetchMealReviewsUseCase: FetchMealReviewsUseCase,
        fetchMealImageReviewsUseCase: FetchMealImageReviewsUseCase
    ) {
        self.mealID = mealID
        self.imageOnly = imageOnly
        self.fetchMealReviewsUseCase = fetchMealReviewsUseCase
        self.fetchMealImageReviewsUseCase = fetchMealImageReviewsUseCase
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

        let thresholdIndex =
            reviews.index(
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
                let response = try await fetchMealReviewsUseCase.execute(
                    menuId: mealID, page: currentPage, perPage: perPage)
                self.hasMorePages = (self.currentPage < (response.totalCount + self.perPage - 1) / self.perPage)
                self.currentPage += 1
                self.getReviewStatus = .succeeded
                self.reviews += response.reviews
            } catch {
                self.getReviewStatus = .failed
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
                let response = try await fetchMealImageReviewsUseCase.execute(
                    menuId: mealID, page: currentPage, perPage: perPage)
                self.hasMorePages = response.hasNext
                self.currentPage += 1
                self.getReviewStatus = .succeeded
                self.reviews += response.reviews
            } catch {
                self.getReviewStatus = .failed
            }
        }
    }

}
