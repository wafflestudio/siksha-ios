//
//  RatingViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/05.
//

import Foundation
import Combine
import UIKit

public class MealInfoViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
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
    @Published var getLikeStatus: NetworkStatus = .idle
    @Published var isLiked = false
    @Published var loadedReviews: Bool = false
    
    init(meal: MenuItemDisplayModel) {
        self.meal = meal
    }
    
    convenience init(meal: Meal) {
        self.init(meal: MenuItemDisplayModel(meal: meal))
    }
    
    func toggleLike(){
        guard getLikeStatus != .loading else{
            return
        }
        
        getLikeStatus = .loading
        
        
        if meal.isLiked{
            Networking.shared.unlikeMenu(menuId: meal.id)
                .map(\.value)
                .receive(on:RunLoop.main)
                .sink { [weak self] response in
                    guard let self = self else { return }
                    guard let response = response else {
                        self.getLikeStatus = .failed
                        return
                    }
                    
                    self.getLikeStatus = .succeeded
                    self.meal = self.meal.updatingLike(isLiked: response.isLiked, likeCount: response.likeCnt)
                }
                .store(in: &cancellables)
        }
        else{
            Networking.shared.likeMenu(menuId: meal.id)
                .map(\.value)
                .receive(on:RunLoop.main)
                .sink { [weak self] response in
                    guard let self = self else { return }
                    guard let response = response else {
                        self.getLikeStatus = .failed
                        return
                    }
                    
                    self.getLikeStatus = .succeeded
                    self.meal = self.meal.updatingLike(isLiked: response.isLiked, likeCount: response.likeCnt)
                }
                .store(in: &cancellables)
        }
    }
    
    func loadReviews() {
        guard getReviewStatus != .loading else {
            return
        }
        
        getReviewStatus = .loading

        Networking.shared.getReviews(menuId: meal.id, page: 1, perPage: 5)
            .map(\.value)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self else { return }
                guard let response = response else {
                    self.getReviewStatus = .failed
                    return
                }
                self.hasMorePages = response.hasNext
                self.getReviewStatus = .succeeded
            })
            .map(\.?.result)
            .replaceNil(with: [])
            .assign(to: \.mealReviews, on: self)
            .store(in: &cancellables)
    }
    
    func loadImages() {
        guard getImageStatus != .loading else {
            return
        }
        
        getImageStatus = .loading
        
        Networking.shared.getReviewImages(menuId: meal.id, page: 1, perPage: 6)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self else { return }
                guard let response = response.value else {
                    self.getImageStatus = .failed
                    return
                }
                self.totalImageCount = response.totalCount
                self.getImageStatus = .succeeded
            })
            .map(\.value?.result)
            .replaceNil(with: [])
            .map { $0.map {$0.etc?["images"]?[0] ?? ""} }
            .assign(to: \.images, on: self)
            .store(in: &cancellables)
    }
    
    func loadDistribution() {
        guard getDistributionStatus != .loading else {
            return
        }
        
        getDistributionStatus = .loading
        
        Networking.shared.getScoreDistribution(menuId: meal.id)
            .map(\.value)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self else { return }
                guard let _ = response else {
                    self.getDistributionStatus = .failed
                    return
                }
                self.getDistributionStatus = .succeeded
            })
            .map(\.?.dist)
            .replaceNil(with: [])
            .map { dist in dist.map { CGFloat($0) } }
            .assign(to: \.scoreDistribution, on: self)
            .store(in: &cancellables)
    }
    
    func loadKeywordDistribution() {
        guard getKeywordDistributionStatus != .loading else {
            return
        }
        
        getKeywordDistributionStatus = .loading
        
        Networking.shared.getKeywordDistribution(menuId: meal.id)
            .map(\.value)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self else { return }
                guard let _ = response else {
                    self.getKeywordDistributionStatus = .failed
                    return
                }
                self.getKeywordDistributionStatus = .succeeded
            })
            .compactMap{ $0 }
            .sink{ [weak self] dist in
                guard let self else { return }
                
                tasteSummary = ReviewKeywordSummary(
                    type: .taste,
                    keyword: dist.tasteKeyword,
                    count: dist.tasteCnt,
                    total: dist.tasteTotal
                )
                
                priceSummary = ReviewKeywordSummary(
                    type: .price,
                    keyword: dist.priceKeyword,
                    count: dist.priceCnt,
                    total: dist.priceTotal
                )
                
                compositionSummary = ReviewKeywordSummary(
                    type: .composition,
                    keyword: dist.foodCompositionKeyword,
                    count: dist.foodCompositionCnt,
                    total: dist.foodCompositionTotal
                )
            }
            .store(in: &cancellables)
    }
    
    /// 서버 MealID로 Meal 호출 속도 느림 -> 불가피하게 아는 정보가 mealId뿐일 때만 사용
    func updateMealFromId() {
        Networking.shared.getMenuFromId(menuId: meal.id)
            .map(\.value)
            .receive(on: RunLoop.main)
            .sink { [weak self] response in
                guard let self = self,
                      let response = response else {
                    return
                }
                self.meal = MenuItemDisplayModel(response: response)
            }
            .store(in: &cancellables)
    }
}

private extension MenuItemDisplayModel {
    init(meal: Meal) {
        self.init(
            id: meal.id,
            code: meal.code,
            nameKr: meal.nameKr,
            nameEn: meal.nameEn,
            price: meal.price,
            score: meal.score,
            reviewCount: meal.reviewCnt,
            isLiked: meal.isLiked,
            likeCount: meal.likeCnt,
            imageURLStrings: Array(meal.etc)
        )
    }
    
    init(response: MenuIdResponse) {
        self.init(
            id: response.id,
            code: response.code,
            nameKr: response.nameKr ?? "",
            nameEn: response.nameEn ?? "",
            price: response.price ?? 0,
            score: response.score ?? 0,
            reviewCount: response.reviewCnt,
            isLiked: response.isLiked,
            likeCount: response.likeCnt,
            imageURLStrings: response.etc
        )
    }
}
