//
//  MealReviewViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/08.
//

import Foundation
import UIKit
import Combine
import RealmSwift
import SwiftUI

class MealReviewViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var meal: Meal? = nil
    @Published var scoreToSubmit: Double = 0 {
        didSet {
            if scoreToSubmit - scoreToSubmit.rounded() == 0 {
                scoreString = String(Int(scoreToSubmit))
            } else {
                scoreString = String(scoreToSubmit)
            }
        }
    }
    @Published var scoreString: String = "0"
    @Published var commentToSubmit: String = ""
    @Published var commentRecommended: Bool = false
    @Published var canSubmit: Bool = false
    
    @Published var postReviewSucceeded = true
    @Published var errorCode: ReviewErrorCode? = nil
    @Published var requireLogin: Bool = false
    @Published var showAlert: Bool = false
    
    @Published var selectedKeywords: [KeywordRateType: String] = [:]
    
    @Published var selectedImages: [UIImage] = []
    
    private var imagesData = [Data]()
    private var recommendedComment = ""
    
    init() {
        $postReviewSucceeded
            .dropFirst()
            .sink { [weak self] status in
                guard let self = self else { return }
                self.showAlert = true
            }
            .store(in: &cancellables)
        
        $commentRecommended
            .dropFirst()
            .filter { !$0 }
            .map { _ in "" }
            .assign(to: \.commentToSubmit, on: self)
            .store(in: &cancellables)
        
        $scoreToSubmit
            .filter { $0 > 0 }
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] score in
                guard let self = self else { return }
                
                if commentToSubmit.isEmpty || commentToSubmit == recommendedComment {
                    self.getRecommendedComment(Int(score))
                }
            }
            .store(in: &cancellables)
        
        $scoreToSubmit
            .combineLatest($selectedKeywords)
            .map { $0 > 0 && $1[KeywordRateType.taste]?.isEmpty == false && $1[KeywordRateType.yang]?.isEmpty == false && $1[KeywordRateType.price]?.isEmpty == false }
            .assign(to: \.canSubmit, on: self)
            .store(in: &cancellables)
        
    }
    
    private func getRecommendedComment(_ score: Int) {
        Networking.shared.getCommentRecommendation(score: score)
            .map(\.value?.comment)
            .replaceNil(with: "")
            .filter({ comment in
                !comment.isEmpty
            })
            .handleEvents(receiveOutput : { comment in
                self.commentRecommended = true
                self.recommendedComment = comment
            })
            .assign(to: \.commentToSubmit, on: self)
            .store(in: &cancellables)
    }
    
    func submitReview() {
        guard let meal = meal else {
            self.postReviewSucceeded = false
            return
        }
        
        // TODO: 아래 더미데이터 교체
        Networking.shared.submitReview(
            menuId: meal.id,
            score: scoreToSubmit,
            comment: commentToSubmit.count > 0 ? commentToSubmit : "",
            taste: "또 먹고 싶어요",
            price: "혜자스러워요",
            foodComposition: "조화로워요"
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] result in
            guard let self = self else { return }
            guard let response = result.response else {
                self.postReviewSucceeded = false
                return
            }
            
            if 200..<300 ~= response.statusCode {
                self.postReviewSucceeded = true
                
                let score = meal.score
                let reviewCnt = meal.reviewCnt
                
                let newScore = (score * Double(reviewCnt) + self.scoreToSubmit) / Double(reviewCnt + 1)
                let newReviewCnt = reviewCnt + 1
                
                let realm = try! Realm()
                try! realm.write {
                    meal.score = newScore
                    meal.reviewCnt = newReviewCnt
                }
            } else {
                self.errorCode = .init(rawValue: response.statusCode)
                self.postReviewSucceeded = false
            }
        }
        .store(in: &cancellables)
    }
    
    func submitReviewImages(images: [UIImage]) {
        guard let meal = meal else {
            self.postReviewSucceeded = false
            return
        }
        
        let imagesData = images.compactMap{ $0.jpegData(compressionQuality: 0.5) }
        
        Networking.shared.submitReviewImages(
            menuId: meal.id,
            score: scoreToSubmit,
            comment: commentToSubmit.count > 0 ? commentToSubmit : "",
            taste: "또 먹고 싶어요",
            price: "혜자스러워요",
            foodComposition: "조화로워요",
            images: imagesData)
        .receive(on: RunLoop.main)
        .sink { [weak self] result in
            guard let self = self else { return }
            guard let response = result.response else {
                self.postReviewSucceeded = false
                return
            }
            
            if 200..<300 ~= response.statusCode {
                self.postReviewSucceeded = true
                
                let score = meal.score
                let reviewCnt = meal.reviewCnt
                
                let newScore = (score * Double(reviewCnt) + self.scoreToSubmit) / Double(reviewCnt + 1)
                let newReviewCnt = reviewCnt + 1
                
                let realm = try! Realm()
                try! realm.write {
                    meal.score = newScore
                    meal.reviewCnt = newReviewCnt
                }
            } else {
                self.errorCode = .init(rawValue: response.statusCode)
                self.postReviewSucceeded = false
            }
        }
        .store(in: &cancellables)
    }
    
    func deleteImage(_ image: UIImage) {
        selectedImages.removeAll {
            $0 == image
        }
    }
    
}
