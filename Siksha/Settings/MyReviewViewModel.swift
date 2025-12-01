//
//  MyReviewViewModel.swift
//  Siksha
//
//  Created by 이수민 on 9/14/25.
//

import Foundation
import Combine
import SwiftyJSON
 
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
    private var cancellables = Set<AnyCancellable>()
    private let repository: UserRepositoryProtocol
    private var currentPage = 1
    private let perPage = 20
    private var hasNext = true
    
    // MARK: - Init
    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }
    
    // MARK: - Public Methods
    func loadReviews() {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage = 1
        
        repository.getMyReview(page: currentPage, perPage: perPage)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                self?.isLoading = false
                
                switch completionStatus {
                case .finished:
                    break
                case .failure:
                    break
                }
            }, receiveValue: { [weak self] response in
                self?.handleReviewResponse(response, isLoadMore: false)
            })
            .store(in: &cancellables)
    }
    
    func loadMoreReviews() {
        guard !isLoading, hasNext else { return }
        
        isLoading = true
        currentPage += 1
        
        repository.getMyReview(page: currentPage, perPage: perPage)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                self?.isLoading = false
                
                switch completionStatus {
                case .finished:
                    break
                case .failure:
                    self?.currentPage -= 1
                }
            }, receiveValue: { [weak self] response in
                self?.handleReviewResponse(response, isLoadMore: true)
            })
            .store(in: &cancellables)
    }
    
    func toggleSection(_ sectionId: Int, expanded: Bool) {
        expandedSections[sectionId] = expanded
    }
    
    func deleteReview(_ reviewId: Int, completion: @escaping (Bool) -> Void) {
        repository.deleteMyReview(reviewId: reviewId)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completionStatus in
                switch completionStatus {
                case .finished:
                    completion(true)
                case .failure(let error):
                    completion(false)
                }
            }, receiveValue: { _ in
            })
            .store(in: &cancellables)
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
    
    private func handleReviewResponse(_ response: MyReviewResponse, isLoadMore: Bool) {
        self.hasNext = response.hasNext
        
        let newSections = response.result.map { restaurant in
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
    
    private func convertToRestaurantSection(_ restaurant: RenewalReviewRestaurant) -> RestaurantSection {
        let reviews = restaurant.reviews.map { review in
            RestaurantReview(
                id: review.id,
                menuId: review.menuId,
                menuName: review.nameKr,
                rating: review.score,
                date: formatDate(review.createdDate),
                reviewText: review.comment,
                imageUrls: [],
                tags: review.keywordReviews.compactMap { $0 }.filter { !$0.isEmpty } 
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
