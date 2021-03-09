//
//  MealReviewViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/08.
//

import Foundation
import Combine


class MealReviewViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var meal: Meal? = nil
    @Published var scoreToSubmit: Double = 0
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
            .combineLatest($commentToSubmit)
            .debounce(for: 0.3, scheduler: RunLoop.main)
            .sink { [weak self] (score, comment) in
                guard let self = self else { return }
                if score > 0 && (comment.count > 0 && comment.count <= 150) {
                    self.canSubmit = true
                } else {
                    self.canSubmit = false
                }
            }
            .store(in: &cancellables)
        
        $commentToSubmit
            .removeDuplicates()
            .map { $0.count }
            .assign(to: \.commentCount, on: self)
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
        json["comment"] = commentToSubmit
        
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
                    } else {
                        self.errorCode = ReviewErrorCode.init(rawValue: response.statusCode)
                        self.postReviewStatus = .failed
                    }
                }
            .store(in: &cancellables)
    }
}
