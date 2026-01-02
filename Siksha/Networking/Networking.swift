//
//  Networking.swift
//  Siksha
//
//  Created by 박종석 on 2021/05/07.
//

import Foundation
import Alamofire
import Combine
import SwiftyJSON

class Networking {
    static let shared = Networking()
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    func testLogin() -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.testLogin)
        return request.validate().publishData()
    }
    
    func getAccessToken(token: String, endPoint: String) -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.getAccessToken(token: token, endPoint: endPoint))
        
        return request.validate().publishData()
    }
    
    func refreshAccessToken(token: String) -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.refreshAccessToken(token: token))
        
        return request.validate().publishData()
    }
    
    func getFestivalDates() -> DataResponsePublisher<FestivalDatesResponse> {
        let request = AF.request(SikshaAPI.getFestivalDates)
        return request.validate().publishDecodable(type: FestivalDatesResponse.self, decoder: JSONDecoder())
    }

    func getMenus(startDate: String, endDate: String, noMenuHide: Bool) -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.getMenus(startDate: startDate, endDate: endDate, noMenuHide: noMenuHide))
        
        return request.validate().publishData()
    }
    func getMenuFromId(menuId:Int)->DataResponsePublisher<MenuIdResponse>{
        let request = AF.request(SikshaAPI.getMenuFromId(menuId: menuId))
        return request.validate().publishDecodable(type:MenuIdResponse.self,decoder: JSONDecoder())
    }
    func getMyLikedMenu()->DataResponsePublisher<MyLikedMenuResponse>{
        let request = AF.request(SikshaAPI.getMyLikedMenu)
        return request.validate().publishDecodable(type:MyLikedMenuResponse.self,decoder: JSONDecoder())
    }
    func likeMenu(menuId:Int)->DataResponsePublisher<MenuIdResponse>{
        let request = AF.request(SikshaAPI.likeMenu(menuId: menuId))
        return request.validate().publishDecodable(type:MenuIdResponse.self,decoder: JSONDecoder())
    }
    func unlikeMenu(menuId:Int)->DataResponsePublisher<MenuIdResponse>{
        let request = AF.request(SikshaAPI.unlikeMenu(menuId: menuId))
        return request.validate().publishDecodable(type:MenuIdResponse.self,decoder: JSONDecoder())
    }
    
    func likeReview(reviewId: Int)->AnyPublisher<Void, AppError>{
        let request = AF.request(SikshaAPI.likeReview(reviewId: reviewId))
        return request
            .validate()
            .publishData(emptyResponseCodes: [204])
            .tryMap { response in
                if let error = response.error {
                    if let data = response.data,
                       let message = try? JSON(data: data)["message"].stringValue {
                        throw AppError.error(message)
                    }
                    switch error {
                    case .responseSerializationFailed(let reason):
                        if case .inputDataNilOrZeroLength = reason {
                            return ()
                        }
                    default: break
                    }
                    throw error
                }
                return ()
            }
            .mapError({ error in
                if let e = error as? AppError {
                    return e
                }
                if let afError = error as? AFError {
                    return .serverError("\(afError.responseCode ?? 0)", afError.localizedDescription)
                }
                return .unknownError("unknown error occurred")
            })
            .eraseToAnyPublisher()
    }
    
    func unlikeReview(reviewId: Int)->AnyPublisher<Void, AppError>{
        let request = AF.request(SikshaAPI.unlikeReview(reviewId: reviewId))
        return request
            .validate(statusCode: 200..<300)
            .publishData(emptyResponseCodes: [204])
            .tryMap { response in
                if let error = response.error {
                    throw error
                }
                return ()
            }
            .mapError({ error in
                if let afError = error as? AFError {
                    return .serverError("\(afError.responseCode ?? 0)", afError.localizedDescription)
                }
                return .unknownError("unknown error occurred")
            })
            .eraseToAnyPublisher()
    }
    func getRestaurants() -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.getRestaurants)
        
        return request.validate().publishData()
    }
    
    func getReviews(menuId: Int, page: Int, perPage: Int) -> DataResponsePublisher<ReviewResponse> {
        let request = AF.request(SikshaAPI.getReviews(menuId: menuId, page: page, perPage: perPage))
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        return request.validate().publishDecodable(type: ReviewResponse.self, decoder: decoder)
    }
    
    func getScoreDistribution(menuId: Int) -> DataResponsePublisher<ScoreDistributionResponse> {
        let request = AF.request(SikshaAPI.getScoreDistribution(menuId: menuId))
        
        return request.validate().publishDecodable(type: ScoreDistributionResponse.self)
    }
    
    func getKeywordDistribution(menuId: Int) -> DataResponsePublisher<KeywordDistributionResponse> {
        let request = AF.request(SikshaAPI.getKeywordDistribution(menuId: menuId))
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return request.validate().publishDecodable(type: KeywordDistributionResponse.self, decoder: decoder)
    }
    
    func getCommentRecommendation(score: Int) -> DataResponsePublisher<CommentRecommendationResponse> {
        let request = AF.request(SikshaAPI.getCommentRecommendation(score: score))
        
        return request.validate().publishDecodable(type: CommentRecommendationResponse.self)
    }
    
    func submitReview(menuId: Int, score: Int, comment: String, taste: String, price: String, foodComposition: String) -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.submitReview(menuId: menuId, score: score, comment: comment, taste: taste, price: price, foodComposition: foodComposition))
        
        return request.validate().publishData()
    }
    
    func submitReviewImages(menuId: Int, score: Int, comment: String, taste: String, price: String, foodComposition: String, images: [Data]) -> DataResponsePublisher<Data> {
        let api = SikshaAPI.submitReviewImages(menuId: menuId, score: score, comment: comment, taste: taste, price: price, foodComposition: foodComposition, images: images)
        let request = AF.upload(multipartFormData: api.multipartFormData!, with: api)
        
        return request.validate().publishData()
    }
    
    func getReviewImages(menuId: Int, page: Int, perPage: Int) -> DataResponsePublisher<ReviewResponse> {
        let request = AF.request(SikshaAPI.getReviewImages(menuId: menuId, page: page, perPage: perPage))
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
        decoder.dateDecodingStrategy = .formatted(formatter)
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return request.validate().publishDecodable(type: ReviewResponse.self, decoder: decoder)
    }
    
    func getUserInfo() -> DataResponsePublisher<UserInfoResponse> {
        let request = AF.request(SikshaAPI.getUserInfo)
        
        return request.validate().publishDecodable(type: UserInfoResponse.self)
    }
    
    func submitVOC(comment: String, platform: String) -> DataResponsePublisher<Data> {
        let request = AF.request(SikshaAPI.submitVOC(comment: comment, platform: platform))
        
        return request.validate().publishData()
    }
}

struct EmptyEntity: Codable, EmptyResponse {
    static func emptyValue() -> EmptyEntity {
        return EmptyEntity.init()
    }
}
