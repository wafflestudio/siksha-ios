//
//  RatingViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/05.
//

import Foundation
import UIKit

public class MealInfoViewModel: ObservableObject {
    private let mealInfoUseCase: MealInfoUseCase
    private let mealReviewUseCase: MealReviewUseCase
    private let menuPreferenceUseCase: MenuPreferenceUseCase
    
    @Published var meal: MenuItemDisplayModel
    @Published var mealReviews: [Review] = []
    @Published var hasMorePages = true
    
    @Published var images: [String] = []
    @Published var totalImageCount = 0
    
    @Published var scoreDistribution: [CGFloat] = []
    @Published var tasteSummary: ReviewKeywordSummary = .init(type: .taste, keyword: "", count: 0, total: 0)
    @Published var priceSummary: ReviewKeywordSummary = .init(type: .price, keyword: "", count: 0, total: 0)
    @Published var compositionSummary: ReviewKeywordSummary = .init(type: .composition, keyword: "", count: 0, total: 0)
    
    @Published var getReviewStatus: NetworkStatus = .idle
    @Published var getImageStatus: NetworkStatus = .idle
    @Published var getDistributionStatus: NetworkStatus = .idle
    @Published var getKeywordDistributionStatus: NetworkStatus = .idle
    @Published var likeStatus: NetworkStatus = .idle
    @Published var isLiked = false
    @Published var loadedReviews: Bool = false
    
    var isUpdatingLike: Bool {
        likeStatus == .loading
    }
    
    init(
        meal: MenuItemDisplayModel,
        mealInfoUseCase: MealInfoUseCase,
        mealReviewUseCase: MealReviewUseCase,
        menuPreferenceUseCase: MenuPreferenceUseCase
    ) {
        self.meal = meal
        self.mealInfoUseCase = mealInfoUseCase
        self.mealReviewUseCase = mealReviewUseCase
        self.menuPreferenceUseCase = menuPreferenceUseCase
    }
    
    func toggleLike(){
        guard likeStatus != .loading else{
            return
        }
        
        likeStatus = .loading
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let menuId = meal.id
                let isCurrentlyLiked = meal.isLiked
                let status: MenuLikeStatusModel
                
                if isCurrentlyLiked {
                    status = try await menuPreferenceUseCase.unlikeMenu(menuId: menuId)
                } else {
                    status = try await menuPreferenceUseCase.likeMenu(menuId: menuId)
                }
                
                await MainActor.run {
                    self.likeStatus = .succeeded
                    self.meal = self.meal.updatingLike(
                        isLiked: status.isLiked,
                        likeCount: status.likeCount
                    )
                }
            } catch {
                await MainActor.run {
                    self.likeStatus = .failed
                }
            }
        }
    }
    
    func loadReviews() {
        guard getReviewStatus != .loading else {
            return
        }
        
        getReviewStatus = .loading

        Task { [weak self] in
            guard let self else { return }
            
            do {
                let response = try await mealReviewUseCase.fetchReviews(menuId: meal.id, page: 1, perPage: 5)
                await MainActor.run {
                    self.hasMorePages = response.hasNext
                    self.getReviewStatus = .succeeded
                    self.mealReviews = response.reviews
                }
            } catch {
                await MainActor.run {
                    self.getReviewStatus = .failed
                }
            }
        }
    }
    
    func loadImages() {
        guard getImageStatus != .loading else {
            return
        }
        
        getImageStatus = .loading
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let response = try await mealReviewUseCase.fetchImageReviews(menuId: meal.id, page: 1, perPage: 6)
                await MainActor.run {
                    self.totalImageCount = response.totalCount
                    self.getImageStatus = .succeeded
                    self.images = response.reviews.map { $0.etc?["images"]?[0] ?? "" }
                }
            } catch {
                await MainActor.run {
                    self.getImageStatus = .failed
                }
            }
        }
    }
    
    func loadDistribution() {
        guard getDistributionStatus != .loading else {
            return
        }
        
        getDistributionStatus = .loading
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let distribution = try await mealReviewUseCase.fetchScoreDistribution(menuId: meal.id)
                await MainActor.run {
                    self.getDistributionStatus = .succeeded
                    self.scoreDistribution = distribution.map { CGFloat($0) }
                }
            } catch {
                await MainActor.run {
                    self.getDistributionStatus = .failed
                }
            }
        }
    }
    
    func loadKeywordDistribution() {
        guard getKeywordDistributionStatus != .loading else {
            return
        }
        
        getKeywordDistributionStatus = .loading
        
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let dist = try await mealReviewUseCase.fetchKeywordDistribution(menuId: meal.id)
                await MainActor.run {
                    self.getKeywordDistributionStatus = .succeeded
                    
                    self.tasteSummary = ReviewKeywordSummary(
                        type: .taste,
                        keyword: dist.tasteKeyword,
                        count: dist.tasteCount,
                        total: dist.tasteTotal
                    )
                    
                    self.priceSummary = ReviewKeywordSummary(
                        type: .price,
                        keyword: dist.priceKeyword,
                        count: dist.priceCount,
                        total: dist.priceTotal
                    )
                    
                    self.compositionSummary = ReviewKeywordSummary(
                        type: .composition,
                        keyword: dist.foodCompositionKeyword,
                        count: dist.foodCompositionCount,
                        total: dist.foodCompositionTotal
                    )
                }
            } catch {
                await MainActor.run {
                    self.getKeywordDistributionStatus = .failed
                }
            }
        }
    }
    
    /// 서버 MealID로 Meal 호출 속도 느림 -> 불가피하게 아는 정보가 mealId뿐일 때만 사용
    func updateMealFromId() {
        Task { [weak self] in
            guard let self else { return }
            
            do {
                let menu = try await mealInfoUseCase.fetchMenu(menuId: meal.id)
                await MainActor.run {
                    self.meal = MenuItemDisplayModel(menu: menu)
                }
            } catch {
                return
            }
        }
    }
}
