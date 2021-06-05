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
    
    func submitReviewImages(menuId: Int, score: Double, comment: String, images: [Data]) -> DataResponsePublisher<Data> {
        let request = AF.upload(multipartFormData: { multipartFormData in
            multipartFormData.append("\(menuId)".data(using: .utf8)!, withName: "menu_id", mimeType: "text/plain")
            multipartFormData.append("\(Int(score))".data(using: .utf8)!, withName: "score", mimeType: "text/plain")
            multipartFormData.append(comment.data(using: .utf8)!, withName: "comment", mimeType: "text/plain")
            for (index, image) in images.enumerated() {
                multipartFormData.append(image, withName: "images", fileName: "image_\(index).png", mimeType: "image/png")
            }
        }, with: SikshaAPI.submitReviewImages)
        
        return request.validate().publishData()
    }
    
    func getReviewImages(menuId: Int, page: Int, perPage: Int, comment: Bool, etc: Bool) -> DataResponsePublisher<ReviewResponse> {
        let request = AF.request(SikshaAPI.getReviewImages(menuId: menuId, page: page, perPage: perPage, comment: comment, etc: etc))
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return request.validate().publishDecodable(type: ReviewResponse.self, decoder: decoder)
    }
}
