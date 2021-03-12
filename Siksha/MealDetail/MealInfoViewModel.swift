//
//  RatingViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/05.
//

import Foundation
import Combine

public class MealInfoViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    var currentPage: Int = 1
    
    @Published var meal: Meal
    @Published var mealReviews: [Review] = []
    @Published var hasMorePages = true
    @Published var getReviewStatus: NetworkStatus = .idle
    
    init(_ meal: Meal) {
        self.meal = meal
    }
    
    func loadMoreReviewsIfNeeded(currentItem item: Review?) {
        guard let item = item else {
            loadMoreReviews()
            return
        }
        
        let thresholdIndex = mealReviews.index(mealReviews.endIndex, offsetBy: -5)
        
        if mealReviews.firstIndex(where: { $0.id == item.id }) == thresholdIndex {
            loadMoreReviews()
        }
    }
    
    private func loadMoreReviews() {
        guard getReviewStatus != .loading else {
            return
        }
        
        getReviewStatus = .loading
        
        let url = Config.shared.baseURL + "/reviews/"
        var component = URLComponents(string: url)
        var parameters = [URLQueryItem]()
        
        parameters.append(URLQueryItem(name: "menu_id", value: "\(meal.id)"))
        parameters.append(URLQueryItem(name: "page", value: "\(currentPage)"))
        parameters.append(URLQueryItem(name: "per_page", value: "10"))
        
        component?.queryItems = parameters
        
        let request = URLRequest(url: component?.url ?? URL(string: url)!)
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(formatter)

        URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: ReviewResponse.self, decoder: decoder)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] response in
                guard let self = self else { return }
                self.hasMorePages = (self.currentPage < (response.totalCount+9)/10)
                self.currentPage += 1
                self.getReviewStatus = .succeeded
            })
            .map { self.mealReviews + $0.reviews }
            .catch { _ -> Just<[Review]> in
                self.getReviewStatus = .failed

                return Just(self.mealReviews)
            }
            .assign(to: \.mealReviews, on: self)
            .store(in: &cancellables)
    }
}
