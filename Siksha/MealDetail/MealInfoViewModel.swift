//
//  RatingViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/05.
//

import Foundation
import Combine
import UIKit
import RealmSwift

public class MealInfoViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var meal: Meal
    @Published var mealReviews: [Review] = []
    @Published var hasMorePages = true
    
    @Published var images: [String] = []
    @Published var totalImageCount = 0
    
    @Published var scoreDistribution: [CGFloat] = []
    
    @Published var getReviewStatus: NetworkStatus = .idle
    @Published var getImageStatus: NetworkStatus = .idle
    @Published var getDistributionStatus: NetworkStatus = .idle
    @Published var getLikeStatus: NetworkStatus = .idle
    @Published var isLiked = false
    @Published var loadedReviews: Bool = false
    
    init(meal: Meal) {
            self.meal = meal
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
                    
                    let realm = try! Realm()
                    try! realm.write {
                        self.meal.isLiked = response.is_liked
                        self.meal.likeCnt = response.like_cnt
                    }
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
                    
                    let realm = try! Realm()
                    try! realm.write {
                        self.meal.isLiked = response.is_liked
                        self.meal.likeCnt = response.like_cnt
                    }
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
                self.hasMorePages = (1 < (response.totalCount+4)/5)
                self.getReviewStatus = .succeeded
            })
            .map(\.?.reviews)
            .replaceNil(with: [])
            .assign(to: \.mealReviews, on: self)
            .store(in: &cancellables)
    }
    
    func loadImages() {
        guard getImageStatus != .loading else {
            return
        }
        
        getImageStatus = .loading
        
        Networking.shared.getReviewImages(menuId: meal.id, page: 1, perPage: 3, comment: false, etc: true)
            .map(\.value)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self else { return }
                guard let response = response else {
                    self.getImageStatus = .failed
                    return
                }
                self.totalImageCount = response.totalCount
                self.getImageStatus = .succeeded
            })
            .map(\.?.reviews)
            .replaceNil(with: [])
            .map { $0.map {$0.images?["images"]?[0] ?? ""} }
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
}
