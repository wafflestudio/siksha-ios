//
//  SikshaAPI.swift
//  Siksha
//
//  Created by 박종석 on 2021/05/07.
//

import Foundation
import Alamofire


enum SikshaAPI: URLRequestConvertible {
    func asURLRequest() throws -> URLRequest {
        var request = URLRequest(url: URL(string: Self.baseURL + path)!)
        
        if self.needToken, let token = UserDefaults.standard.string(forKey: "accessToken") {
            request.setToken(token: token)
        }
        
        if self.askingForToken {
            switch self {
            case let .getAccessToken(token, endPoint):
                request.setToken(token: token, type: endPoint)
            default:
                break
            }
        }
        
        if self.multiPartFormDataNeeded{
            request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 3
        }
        
        #if DEBUG
        print(Self.baseURL + path)
        #endif
        
        request.method = self.method
        switch self.method {
        case .get:
            return try Alamofire.URLEncoding.default.encode(request, with: self.parameters)
        default:
            return try Alamofire.JSONEncoding.default.encode(request, with: self.parameters)
        }
    }
    
    case getAccessToken(token: String, endPoint: String)
    case refreshAccessToken(token: String)
    case getMenus(startDate: String, endDate: String, noMenuHide: Bool)
    case getMenuFromId(menuId: Int)
    case likeMenu(menuId:Int)
    case unlikeMenu(menuId:Int)
    case getRestaurants
    case getReviews(menuId: Int, page: Int, perPage: Int)
    case getScoreDistribution(menuId: Int)
    case getCommentRecommendation(score: Int)
    case submitReview(menuId: Int, score: Double, comment: String)
    case submitReviewImages(menuId: Int, score: Double, comment: String, images: [Data])
    case getReviewImages(menuId: Int, page: Int, perPage: Int, comment: Bool, etc: Bool)
    case getUserInfo
    case submitVOC(comment: String, platform: String)
    
    static var baseURL = Config.shared.baseURL!
    
    var needToken: Bool {
        switch self {
        case .getAccessToken:
            return false
        case .getMenus:
            return true
        case .getMenuFromId:
            return true
        case .getRestaurants:
            return false
        case .getReviews:
            return false
        case .getScoreDistribution:
            return false
        case .getCommentRecommendation:
            return false
        case .likeMenu:
            return true
        case .unlikeMenu:
            return true
        default:
            return true
        }
    }
    
    var askingForToken: Bool {
        switch self {
        case .getAccessToken:
            return true
        default:
            return false
        }
    }
    
    var method: HTTPMethod {
        switch self {
        case .getAccessToken:
            return .post
        case .refreshAccessToken:
            return .post
        case .getMenus:
            return .get
        case .getMenuFromId:
            return .get
        case .getRestaurants:
            return .get
        case .getReviews:
            return .get
        case .getScoreDistribution:
            return .get
        case .getCommentRecommendation:
            return .get
        case .submitReview:
            return .post
        case .submitReviewImages:
            return .post
        case .likeMenu:
            return .post
        case .unlikeMenu:
            return .post
        case .getReviewImages:
            return .get
        case .getUserInfo:
            return .get
        case .submitVOC:
            return .post
        
        }
    }

    var path: String {
        switch self {
        case let .getAccessToken(_, endPoint):
            return "/auth/login/\(endPoint)"
        case .refreshAccessToken:
            return "/auth/refresh"
        case .getMenus:
            return "/menus/lo"
        case let .getMenuFromId(menuId):
            return "/menus/\(menuId)"
        case let .likeMenu(menuId):
            return "/menus/\(menuId)/like"
        case let .unlikeMenu(menuId):
            return "/menus/\(menuId)/unlike"
        case .getRestaurants:
            return "/restaurants/"
        case .getReviews:
            return "/reviews/"
        case .getScoreDistribution:
            return "/reviews/dist"
        case .getCommentRecommendation:
            return "/reviews/comments/recommendation"
        case .submitReview:
            return "/reviews/"
        case .submitReviewImages:
            return "/reviews/images"
        case .getReviewImages:
            return "/reviews/filter/"
        case .getUserInfo:
            return "/auth/me"
        case .submitVOC:
            return "/voc"
            
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getAccessToken:
            return nil
        case .refreshAccessToken:
            return nil
        case let .getMenus(startDate, endDate, noMenuHide):
            return ["start_date": startDate, "end_date": endDate, "except_empty": noMenuHide]
        case .getMenuFromId:
            return nil
        case .getRestaurants:
            return nil
        case let .getReviews(menuId, page, perPage):
            return ["menu_id": menuId, "page": page, "per_page": perPage]
        case let .getScoreDistribution(menuId):
            return ["menu_id": menuId]
        case let .getCommentRecommendation(score):
            return ["score": score]
        case let .submitReview(menuId, score, comment):
            return ["menu_id": menuId, "score": score, "comment": comment]
        case .submitReviewImages:
            return nil
        case .likeMenu:
            return nil
        case .unlikeMenu:
            return nil
        case let .getReviewImages(menuId, page, perPage, comment, etc):
            return ["menu_id": menuId, "page": page, "per_page": perPage, "comment": comment, "etc": etc]
        case .getUserInfo:
            return nil
        case let .submitVOC(comment, platform):
            return ["voc": comment, "platform": platform]
        }
    }
    
    var multiPartFormDataNeeded: Bool {
        switch self {
        case .submitReviewImages:
            return true
        default:
            return false
        }
    }
    
    var multipartFormData: MultipartFormData? {
        switch self {
        case let .submitReviewImages(menuId, score, comment, images):
            let data = MultipartFormData()
            data.append("\(menuId)".data(using: .utf8)!, withName: "menu_id", mimeType: "text/plain")
            data.append("\(Int(score))".data(using: .utf8)!, withName: "score", mimeType: "text/plain")
            data.append(comment.data(using: .utf8)!, withName: "comment", mimeType: "text/plain")
            for (index, image) in images.enumerated() {
                data.append(image, withName: "images", fileName: "image_\(index).jpeg", mimeType: "image/jpeg")
            }
            return data
        default:
            return nil
        }
    }
}
