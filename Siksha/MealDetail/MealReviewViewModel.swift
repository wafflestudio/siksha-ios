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
    
    @Published var postReviewStatus: NetworkStatus = .idle
    @Published var errorCode: ReviewErrorCode? = nil
    @Published var requireLogin: Bool = false
    @Published var showAlert: Bool = false
    
    init() {
        $postReviewStatus
            .filter { $0 != .loading && $0 != .idle }
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
        let url = Config.shared.baseURL + "/reviews/comments/recommendation"
        
        var component = URLComponents(string: url)
        var parameters = [URLQueryItem]()
        
        parameters.append(URLQueryItem(name: "score", value: "\(score)"))
        
        component?.queryItems = parameters
        
        let request = URLRequest(url: component?.url ?? URL(string: url)!)
        
        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: CommentRecommendationResponse.self, decoder: JSONDecoder())
            .receive(on: RunLoop.main)
            .map(\.comment)
            .catch { _ in
                Just("")
            }
            .assign(to: \.commentPlaceHolder, on: self)
            .store(in: &cancellables)
    }
    
    func submitReview() {
        guard let meal = meal else {
            return
        }
        
        postReviewStatus = .loading
        let url = Config.shared.baseURL + "/reviews/"
        
        var json = [String : Any]()
        
        json["menu_id"] = meal.id
        json["score"] = scoreToSubmit
        json["comment"] = commentToSubmit.count > 0 ? commentToSubmit : commentPlaceHolder
        
        guard let data = try? JSONSerialization.data(withJSONObject: json, options: []),
              var request = try? URLRequest(url: URL(string: url)!, method: .post),
              let token = UserDefaults.standard.string(forKey: "accessToken") else {
            self.postReviewStatus = .failed
            return
        }
        
        request.setToken(token: token)
        request.httpBody = data
        
        URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: RunLoop.main)
            .sink { completion in
                if case .failure = completion {
                    self.errorCode = .noNetwork
                    self.postReviewStatus = .failed
                }
            } receiveValue: { [weak self] (data, response) in
                    guard let self = self else { return }
                    guard let response = response as? HTTPURLResponse else {
                        self.postReviewStatus = .failed
                        return
                    }
                    if 200..<300 ~= response.statusCode {
                        self.postReviewStatus = .succeeded
                        
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
                        self.errorCode = ReviewErrorCode.init(rawValue: response.statusCode)
                        self.postReviewStatus = .failed
                    }
                }
            .store(in: &cancellables)
    }
}
