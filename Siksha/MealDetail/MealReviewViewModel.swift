//
//  MealReviewViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/08.
//

import Foundation
import Combine
import Realm
import RealmSwift

class MealReviewViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var meal: Meal? = nil
    @Published var scoreToSubmit: Double = 0
    @Published var commentPlaceHolder: String = ""
    @Published var commentToSubmit: String = ""
    @Published var commentCount: Int = 0
    @Published var canSubmit: Bool = false
    
    @Published var postReviewSucceeded = true
    @Published var errorCode: ReviewErrorCode? = nil
    @Published var requireLogin: Bool = false
    @Published var showAlert: Bool = false
    
    private var imagesData = [Data]()
    
    init() {
        $postReviewSucceeded
            .dropFirst()
            .sink { [weak self] status in
                guard let self = self else { return }
                self.showAlert = true
            }
            .store(in: &cancellables)
        
        $scoreToSubmit
            .filter { $0 > 0 }
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] score in
                guard let self = self else { return }
                
                if self.commentToSubmit.count == 0 {
                    self.getRecommendedComment(Int(score))
                }
            }
            .store(in: &cancellables)
        
        $commentToSubmit
            .removeDuplicates()
            .map { $0.count }
            .assign(to: \.commentCount, on: self)
            .store(in: &cancellables)
        
        $commentPlaceHolder
            .removeDuplicates()
            .map { $0.count }
            .handleEvents (receiveOutput : { count in
                if count > 0 {
                    self.commentToSubmit = ""
                }
            })
            .assign(to: \.commentCount, on: self)
            .store(in: &cancellables)
        
        $scoreToSubmit
            .combineLatest($commentCount)
            .map { $0 > 0 && $1 > 0 }
            .assign(to: \.canSubmit, on: self)
            .store(in: &cancellables)
        
    }
    
    private func getRecommendedComment(_ score: Int) {
        Networking.shared.getCommentRecommendation(score: score)
            .map(\.value?.comment)
            .replaceNil(with: "")
            .assign(to: \.commentPlaceHolder, on: self)
            .store(in: &cancellables)
    }
    
    func submitReview() {
        guard let meal = meal else {
            self.postReviewSucceeded = false
            return
        }

        Networking.shared.submitReview(
            menuId: meal.id,
            score: scoreToSubmit,
            comment: commentToSubmit.count > 0 ? commentToSubmit : commentPlaceHolder)
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
//                    self.errorCode = .init(rawValue: response.statusCode)
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
        
        let imagesData = images.compactMap{ $0.jpegData(compressionQuality: 0) }
        
        Networking.shared.submitReviewImages(
            menuId: meal.id,
            score: scoreToSubmit,
            comment: commentToSubmit.count > 0 ? commentToSubmit : commentPlaceHolder,
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
    
}
