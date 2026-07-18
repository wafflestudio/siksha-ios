//
//  MyReviewViewModel.swift
//  Siksha
//
//  Created by 이수민 on 9/14/25.
//

import Foundation

struct RestaurantSection: Identifiable {
    let id: Int
    let name: String
    let reviews: [RestaurantReview]
}

struct RestaurantReview: Identifiable {
    let id: Int
    let menuId: Int
    let menuName: String
    let rating: Int
    let date: String
    let reviewText: String
    let imageUrls: [String]
    let tags: [String]
}

@MainActor
class MyReviewViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var restaurantSections: [RestaurantSection] = []
    @Published var isLoading = false
    @Published var expandedSections: [Int: Bool] = [:]

    // MARK: - Private Properties
    private let fetchMyReviewsUseCase: FetchMyReviewsUseCase
    private let deleteMyReviewUseCase: DeleteMyReviewUseCase
    private var currentPage = 1
    private let perPage = 20
    private var hasNext = true

    // MARK: - Init
    init(
        fetchMyReviewsUseCase: FetchMyReviewsUseCase,
        deleteMyReviewUseCase: DeleteMyReviewUseCase
    ) {
        self.fetchMyReviewsUseCase = fetchMyReviewsUseCase
        self.deleteMyReviewUseCase = deleteMyReviewUseCase
    }

    // MARK: - Public Methods
    func loadReviews() {
        guard !isLoading else { return }

        isLoading = true
        currentPage = 1

        Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await fetchMyReviewsUseCase.execute(page: currentPage, perPage: perPage)
                handleReviewResponse(response, isLoadMore: false)
            } catch {
            }

            isLoading = false
        }
    }

    func loadMoreReviews() {
        guard !isLoading, hasNext else { return }

        isLoading = true
        currentPage += 1

        Task { [weak self] in
            guard let self else { return }

            do {
                let response = try await fetchMyReviewsUseCase.execute(page: currentPage, perPage: perPage)
                handleReviewResponse(response, isLoadMore: true)
            } catch {
                currentPage -= 1
            }

            isLoading = false
        }
    }

    func toggleSection(_ sectionId: Int, expanded: Bool) {
        expandedSections[sectionId] = expanded
    }

    func deleteReview(_ reviewId: Int, completion: @escaping (Bool) -> Void) {
        Task { [weak self] in
            guard let self else { return }

            do {
                try await deleteMyReviewUseCase.execute(reviewId: reviewId)
                completion(true)
            } catch {
                completion(false)
            }
        }
    }

    func removeReviewFromSection(reviewId: Int) {
        for (index, section) in restaurantSections.enumerated() {
            if let reviewIndex = section.reviews.firstIndex(where: { $0.id == reviewId }) {
                var updatedReviews = section.reviews
                updatedReviews.remove(at: reviewIndex)

                if updatedReviews.isEmpty {
                    restaurantSections.remove(at: index)
                } else {
                    let updatedSection = RestaurantSection(
                        id: section.id,
                        name: section.name,
                        reviews: updatedReviews
                    )
                    restaurantSections[index] = updatedSection
                }
                break
            }
        }
    }

    private func handleReviewResponse(_ response: MyReviewPageModel, isLoadMore: Bool) {
        self.hasNext = response.hasNext

        let newSections = response.restaurants.map { restaurant in
            convertToRestaurantSection(restaurant)
        }

        if isLoadMore {
            self.restaurantSections.append(contentsOf: newSections)
        } else {
            self.restaurantSections = newSections

            for (index, section) in newSections.enumerated() {
                if self.expandedSections[section.id] == nil {
                    self.expandedSections[section.id] = (index == 0)
                }
            }
        }
    }

    private func convertToRestaurantSection(_ restaurant: MyReviewRestaurantModel) -> RestaurantSection {
        let reviews = restaurant.reviews.map { review in
            RestaurantReview(
                id: review.id,
                menuId: review.menuId,
                menuName: review.nameKr,
                rating: review.score,
                date: formatDate(review.createdAt),
                reviewText: review.comment,
                imageUrls: review.etc?["images"] ?? [],
                tags: review.keywordReviews.filter { !$0.isEmpty }
            )
        }

        return RestaurantSection(
            id: restaurant.restaurantId,
            name: restaurant.nameKr,
            reviews: reviews
        )
    }

    private func formatDate(_ date: Date?) -> String {
        guard let date = date else { return "" }

        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 M월 d일"
        return formatter.string(from: date)
    }

}
