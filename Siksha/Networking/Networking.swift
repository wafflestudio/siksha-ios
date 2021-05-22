//
//  Networking.swift
//  Siksha
//
//  Created by 박종석 on 2021/05/07.
//

import Foundation
import Alamofire
import Combine

class Networking {
    static let shared = Networking()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func getAccessToken(token: String, endPoint: String) -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.getAccessToken(token: token, endPoint: endPoint))
        
        return request.validate().publishData()
    }

    func getMenus(startDate: String, endDate: String, noMenuHide: Bool) -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.getMenus(startDate: startDate, endDate: endDate, noMenuHide: noMenuHide))
        
        return request.validate().publishData()
    }
    
    func getRestaurants() -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.getRestaurants)
        
        return request.validate().publishData()
    }
    
    func getReviews(menuId: Int, page: Int, perPage: Int) -> DataResponsePublisher<ReviewResponse> {
        let request = AF.request(SikshaAPI.getReviews(menuId: menuId, page: page, perPage: perPage))
        
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return request.validate().publishDecodable(type: ReviewResponse.self, decoder: decoder)
    }
    
    func getCommentRecommendation(score: Int) -> DataResponsePublisher<CommentRecommendationResponse> {
        let request = AF.request(SikshaAPI.getCommentRecommendation(score: score))
        
        return request.validate().publishDecodable(type: CommentRecommendationResponse.self)
    }
    
    func submitReview(menuId: Int, score: Double, comment: String) -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.submitReview(menuId: menuId, score: score, comment: comment))
        
        return request.validate().publishData()
    }
}
