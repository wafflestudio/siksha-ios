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
    case getMenus(startDate: String, endDate: String, noMenuHide: Bool)
    case getRestaurants
    case getReviews(menuId: Int, page: Int, perPage: Int)
    case getCommentRecommendation(score: Int)
    case submitReview(menuId: Int, score: Double, comment: String)
    
    static var baseURL = Config.shared.baseURL!
    
    var needToken: Bool {
        switch self {
        case .getAccessToken:
            return false
        case .getMenus:
            return false
        case .getRestaurants:
            return false
        case .getReviews:
            return false
        case .getCommentRecommendation:
            return false
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
        case .getMenus:
            return .get
        case .getRestaurants:
            return .get
        case .getReviews:
            return .get
        case .getCommentRecommendation:
            return .get
        case .submitReview:
            return .post
        }
    }

    var path: String {
        switch self {
        case let .getAccessToken(_, endPoint):
            return "/auth/login/\(endPoint)"
        case .getMenus:
            return "/menus/"
        case .getRestaurants:
            return "/restaurants/"
        case .getReviews:
            return "/reviews/"
        case .getCommentRecommendation:
            return "/reviews/comments/recommendation"
        case .submitReview:
            return "/reviews/"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case .getAccessToken:
            return nil
        case let .getMenus(startDate, endDate, noMenuHide):
            return ["start_date": startDate, "end_date": endDate, "except_empty": noMenuHide]
        case .getRestaurants:
            return nil
        case let .getReviews(menuId, page, perPage):
            return ["menu_id": menuId, "page": page, "per_page": perPage]
        case let .getCommentRecommendation(score):
            return ["score": score]
        case let .submitReview(menuId, score, comment):
            return ["menu_id": menuId, "score": score, "comment": comment]
        }
    }
}
