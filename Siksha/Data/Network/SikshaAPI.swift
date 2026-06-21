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
        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
        
        if self.needToken, let token = accessToken {
            request.setToken(token: token)
        }
        
        if self.askingForToken {
            switch self {
            case let .getAccessToken(token, _):
                request.setToken(token: token)
            default:
                break
            }
        }
        
        if self.multiPartFormDataNeeded{
            request.setValue("multipart/form-data", forHTTPHeaderField: "Content-Type")
            request.timeoutInterval = 3
        }
        
        #if DEBUG
        print("""
        ---- Siksha API Request ----
        Method: \(method.rawValue.uppercased())
        URL: \(Self.baseURL + path)
        Needs Token: \(needToken)
        Access Token: \(formattedAccessTokenForDebugLog(accessToken))
        Multipart: \(multiPartFormDataNeeded)
        Parameters:
        \(formattedParametersForDebugLog)
        ----------------------------
        """)
        #endif
        
        request.method = self.method
        switch self.method {
        case .get:
            return try Alamofire.URLEncoding.default.encode(request, with: self.parameters)
        default:
            return try Alamofire.JSONEncoding.default.encode(request, with: self.parameters)
        }
    }
    
    // AUTH
    case getAccessToken(token: String, endPoint: String)
    case refreshAccessToken(token: String)
    case testLogin
    case getUserInfo
    case updateUserProfile(nickname: String?, image: Data?, changeToDefaultImage: Bool)
    case deleteUser
    case postUserDevice(fcmToken: String)
    case deleteUserDevice(fcmToken: String)
    case getAlarmTime
    case setAlarmTime(alarmTime: String)
    
    // MENUS
    case getMenus(startDate: String, endDate: String, noMenuHide: Bool)
    case getMenuFromId(menuId: Int)
    case getMyLikedMenu
    case likeMenu(menuId: Int)
    case unlikeMenu(menuId: Int)
    case getFestivalDates
    case alarmOn(menuId: Int)
    case alarmOff(menuId: Int)
    case alarmOnAll
    case alarmOffAll
    
    // RESTAURANTS
    case getRestaurants
    case getPersonalRestaurants
    case setRestaurantLike(restaurantId: Int, like: Bool)
    case setRestaurantVisible(restaurantId: Int, visible: Bool)
    case getRestaurantOrder
    case setRestaurantOrder(order: [Int])
    
    // REVIEWS
    case getReviews(menuId: Int, page: Int, perPage: Int)
    case submitReview(menuId: Int, score: Int, comment: String, taste: String, price: String, foodComposition: String)
    case getScoreDistribution(menuId: Int)
    case getKeywordDistribution(menuId: Int)
    case getCommentRecommendation(score: Int)
    case submitReviewImages(menuId: Int, score: Int, comment: String, taste: String, price: String, foodComposition: String, images: [Data])
    case getImageReviews(menuId: Int, page: Int, perPage: Int)
    case likeReview(reviewId: Int)
    case unlikeReview(reviewId: Int)
    case getMyReview(page: Int, perPage: Int)
    case deleteMyReview(reviewId: Int)
    case editReview(reviewId: Int, menuId: Int, score: Int, comment: String?, taste: String, price: String, foodComposition: String, images: [Data]?)
    
    // COMMUNITY
    case getBoards
    case getPosts(boardId: Int, page: Int, perPage: Int)
    case getTrendingPosts(likes: Int,created_before: Int)
    case getMyposts(page: Int, perPage: Int)
    case getPost(postId: Int)
    case submitPost(boardId: Int, title: String, content: String, images: [Data], anonymous: Bool)
    case editPost(postId: Int, boardId: Int, title: String, content: String, images: [Data], anonymous: Bool)
    case deletePost(postId: Int)
    case likePost(postId: Int)
    case unlikePost(postId: Int)
    case reportPost(postId: Int, reason: String)
    case getComments(postId: Int, page: Int, perPage: Int)
    case submitComment(postId: Int, content: String, anonymous: Bool)
    case editComment(commentId: Int, content: String)
    case deleteComment(commentId: Int)
    case likeComment(commentId: Int)
    case unlikeComment(commentId: Int)
    case reportComment(commentId: Int, reason: String)

    // VOC
    case submitVOC(comment: String, platform: String)
    
    static var baseURL = Config.shared.baseURL
    
    var needToken: Bool {
        switch self {
        case .getAccessToken:
            return false
        case .testLogin:
            return false
        case .getFestivalDates:
            return false
        case .getRestaurants:
            return false
        case .getScoreDistribution:
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
        case .getAccessToken, .refreshAccessToken, .testLogin:
            return .post
        case .getUserInfo:
            return .get
        case .updateUserProfile:
            return .patch
        case .deleteUser:
            return .delete
        case .postUserDevice:
            return .post
        case .deleteUserDevice:
            return .delete
        case .getAlarmTime:
            return .get
        case .setAlarmTime:
            return .post
            
        case .getMenus, .getMenuFromId, .getMyLikedMenu:
            return .get
        case .likeMenu, .unlikeMenu:
            return .post
        case .getFestivalDates:
            return .get
        case .alarmOn(menuId: _), .alarmOff(menuId: _), .alarmOnAll, .alarmOffAll:
            return .post
            
        case .getRestaurants, .getPersonalRestaurants:
            return .get
        case .setRestaurantLike, .setRestaurantVisible:
            return .patch
        case .getRestaurantOrder:
            return .get
        case .setRestaurantOrder:
            return .patch
            
        case .getReviews:
            return .get
        case .submitReview:
            return .post
        case .getScoreDistribution, .getKeywordDistribution, .getCommentRecommendation:
            return .get
        case .submitReviewImages:
            return .post
        case .getImageReviews:
            return .get
        case .likeReview:
            return .post
        case .unlikeReview:
            return .delete
        case .getMyReview:
            return .get
        case .deleteMyReview:
            return .delete
        case .editReview:
            return .patch
        
        case .getBoards:
            return .get
        case .getPosts, .getTrendingPosts, .getMyposts:
            return .get
        case .getPost:
            return .get
        case .submitPost:
            return .post
        case .editPost:
            return .patch
        case .deletePost:
            return .delete
        case .likePost, .unlikePost, .reportPost:
            return .post
        case .getComments:
            return .get
        case .submitComment:
            return .post
        case .editComment:
            return .patch
        case .deleteComment:
            return .delete
        case .likeComment, .unlikeComment, .reportComment:
            return .post
        
        case .submitVOC:
            return .post
        }
    }

    var path: String {
        switch self {
        // AUTH
        case let .getAccessToken(_, endPoint):
            return "/auth/login/\(endPoint)"
        case .refreshAccessToken:
            return "/auth/refresh"
        case .testLogin:
            return "/auth/login/test"
        case .getUserInfo:
            return "/auth/me"
        case .updateUserProfile:
            return "/auth/me/profile"
        case .deleteUser:
            return "/auth"
        case .postUserDevice:
            return "/auth/userDevice"
        case .deleteUserDevice:
            return "/auth/userDevice"
        case .getAlarmTime:
            return "/auth/alarm"
        case .setAlarmTime:
            return "/auth/alarm"
            
        // MENUS
        case .getMenus:
            return "/menus"
        case let .getMenuFromId(menuId):
            return "/menus/\(menuId)"
        case .getMyLikedMenu:
            return "/menus/me"
        case let .likeMenu(menuId):
            return "/menus/\(menuId)/like"
        case let .unlikeMenu(menuId):
            return "/menus/\(menuId)/unlike"
        case .getFestivalDates:
            return "/menus/festival/dates"
        case .alarmOn(menuId: let menuId):
            return "/menus/\(menuId)/alarm/on"
        case .alarmOff(menuId: let menuId):
            return "/menus/\(menuId)/alarm/off"
        case .alarmOnAll:
            return "/menus/alarm/on"
        case .alarmOffAll:
            return "/menus/alarm/off"
            
        // RESTAURANTS
        case .getRestaurants:
            return "/restaurants"
        case .getPersonalRestaurants:
            return "/restaurants/personal"
        case let .setRestaurantLike(restaurantId, _):
            return "/restaurants/like/\(restaurantId)"
        case let .setRestaurantVisible(restaurantId, _):
            return "/restaurants/visible/\(restaurantId)"
        case .getRestaurantOrder, .setRestaurantOrder:
            return "/restaurants/order"
            
        // REVIEWS
        case .getReviews:
            return "/reviews"
        case .submitReview:
            return "/reviews"
        case .getScoreDistribution:
            return "/reviews/dist"
        case .getKeywordDistribution:
            return "/reviews/keyword/dist"
        case .getCommentRecommendation:
            return "/reviews/comments/recommendation"
        case .submitReviewImages:
            return "/reviews/images"
        case .getImageReviews:
            return "/reviews/filter"
        case let .likeReview(reviewId):
            return "/reviews/\(reviewId)/like"
        case let .unlikeReview(reviewId):
            return "/reviews/\(reviewId)/like"
        case .getMyReview:
            return "/reviews/me"
        case let .deleteMyReview(reviewId):
            return "/reviews/\(reviewId)"
        case let .editReview(reviewId, _, _, _, _, _, _, _):
            return "/reviews/\(reviewId)"
            
        // COMMUNITY
        case .getBoards:
            return "/community/boards"
        case .getPosts:
            return "/community/posts"
        case .getTrendingPosts:
            return "/community/posts/popular/trending"
        case .getMyposts:
            return "/community/posts/me"
        case let .getPost(postId):
            return "/community/posts/\(postId)"
        case .submitPost:
            return "/community/posts"
        case .editPost(postId: let postId, boardId: _, title: _, content: _, images: _, anonymous: _):
            return "/community/posts/\(postId)"
        case let .deletePost(postId):
            return "/community/posts/\(postId)"
        case let .likePost(postId):
            return "/community/posts/\(postId)/like"
        case let .unlikePost(postId):
            return "/community/posts/\(postId)/unlike"
        case let .reportPost(postId, _):
            return "/community/posts/\(postId)/report"
        case .getComments:
            return "/community/comments"
        case .submitComment:
            return "/community/comments"
        case let .editComment(commentId, _):
            return "/community/comments/\(commentId)"
        case let .deleteComment(commentId):
            return "/community/comments/\(commentId)"
        case let .likeComment(commentId):
            return "/community/comments/\(commentId)/like"
        case let .unlikeComment(commentId):
            return "/community/comments/\(commentId)/unlike"
        case let .reportComment(commentId, _):
            return "/community/comments/\(commentId)/report"
            
        // VOC
        case .submitVOC:
            return "/voc"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case let .getMenus(startDate, endDate, noMenuHide):
            return ["start_date": startDate, "end_date": endDate, "except_empty": noMenuHide]
        case let .getReviews(menuId, page, perPage):
            return ["menu_id": menuId, "page": page, "size": perPage]
        case let .setRestaurantLike(_, like):
            return ["like": like]
        case let .setRestaurantVisible(_, visible):
            return ["visible": visible]
        case let .setRestaurantOrder(order):
            return ["order": order]
        case let .getScoreDistribution(menuId):
            return ["menu_id": menuId]
        case let .getKeywordDistribution(menuId):
            return ["menu_id": menuId]
        case let .getCommentRecommendation(score):
            return ["score": score]
        case let .submitReview(menuId, score, comment, taste, price, foodComposition):
            return ["menu_id": menuId, "score": score, "comment": comment, "taste": taste, "price": price, "food_composition": foodComposition]
        case let .getImageReviews(menuId, page, perPage):
            return ["menu_id": menuId, "page": page, "size": perPage, "image": true]
        case let .submitVOC(comment, platform):
            return ["voc": comment, "platform": platform]
        case let .getPosts(boardId, page, perPage):
            return ["board_id": boardId, "page": page, "per_page": perPage]
        case let .getTrendingPosts(likes, created_before):
            return ["likes":likes,"created_before":created_before]
        case let .getMyposts(page, perPage):
            return ["page":page, "per_page":perPage]
        case let .getPost(postId):
            return ["post_id": postId]
        case let .likePost(postId):
            return ["post_id": postId]
        case let .unlikePost(postId):
            return ["post_id": postId]
        case let .getComments(postId, page, perPage):
            return ["post_id": postId, "page": page, "per_page": perPage]
        case let .submitComment(postId, content, anonymous):
            return ["post_id": postId, "content": content, "anonymous": anonymous]
        case let .editPost(postId, _, _, _, _, _):
            return ["post_id": postId]
        case let .editComment(_, content):
            return ["content": content]
     
        case let .likeComment(commentId):
            return ["comment_id": commentId]
        case let .unlikeComment(commentId):
            return ["comment_id": commentId]
        
        case let .reportPost(postId, reason):
            return ["post_id": postId,"reason":reason]
        case let .reportComment(commentId, reason):
            return ["comment_id" : commentId,"reason":reason]
        case let .getMyReview(page, perPage):
            return ["page": page, "per_page": perPage]
        case let .editReview(_, menuId, score, comment, taste, price, foodComposition, _):
            var parameters: [String: Any] = ["menu_id": menuId, "score": score, "taste": taste, "price": price, "food_composition": foodComposition]
            if let comment {
                parameters["comment"] = comment
            }
            return parameters
        case let .postUserDevice(fcmToken):
            return ["fcm_token" : fcmToken]
        case let .deleteUserDevice(fcmToken):
            return ["fcm_token" : fcmToken]
        
        case let .setAlarmTime(alarmTime):
            return ["type": alarmTime]
        case .testLogin:
            return ["identity": "test user"]
        default:
            return nil
        }
    }

    #if DEBUG
    private var formattedParametersForDebugLog: String {
        guard let parameters else {
            return "  nil"
        }

        if JSONSerialization.isValidJSONObject(parameters),
           let data = try? JSONSerialization.data(withJSONObject: parameters, options: [.prettyPrinted, .sortedKeys]),
           let json = String(data: data, encoding: .utf8) {
            return json
                .split(separator: "\n", omittingEmptySubsequences: false)
                .map { "  \($0)" }
                .joined(separator: "\n")
        }

        return "  \(parameters)"
    }

    private func formattedAccessTokenForDebugLog(_ token: String?) -> String {
        guard let token else {
            return "nil"
        }

        guard !token.isEmpty else {
            return "<empty>"
        }

        guard token.count > 12 else {
            return "<\(token.count) characters>"
        }

        return "\(token.prefix(6))...\(token.suffix(6))"
    }
    #endif
    
    var multiPartFormDataNeeded: Bool {
        switch self {
        case .updateUserProfile:
            return true
        case .submitReviewImages:
            return true
        case .editReview:
            return true
        case .submitPost:
            return true
        case .editPost:
            return true
        default:
            return false
        }
    }
    
    var multipartFormData: MultipartFormData? {
        switch self {
        case let .updateUserProfile(nickname, image, changeToDefaultImage):
            let data = MultipartFormData()
            if let nickname {
                data.append("\(nickname)".data(using: .utf8)!, withName: "nickname", mimeType: "text/plain")
            }
            if let image {
                data.append(image, withName: "image", fileName: "profileImage.jpeg", mimeType: "image/jpeg")
            }
            if changeToDefaultImage {
                data.append("true".data(using: .utf8)!, withName: "change_to_default_image", mimeType: "text/plain")
            } else {
                data.append("false".data(using: .utf8)!, withName: "change_to_default_image", mimeType: "text/plain")
            }
            return data
        case let .submitReviewImages(menuId, score, comment, taste, price, foodComposition, images):
            let data = MultipartFormData()
            data.append("\(menuId)".data(using: .utf8)!, withName: "menu_id", mimeType: "text/plain")
            data.append("\(Int(score))".data(using: .utf8)!, withName: "score", mimeType: "text/plain")
            data.append(comment.data(using: .utf8)!, withName: "comment", mimeType: "text/plain")
            data.append(taste.data(using: .utf8)!, withName: "taste", mimeType: "text/plain")
            data.append(price.data(using: .utf8)!, withName: "price", mimeType: "text/plain")
            data.append(foodComposition.data(using: .utf8)!, withName: "food_composition", mimeType: "text/plain")
            for (index, image) in images.enumerated() {
                data.append(image, withName: "images", fileName: "image_\(index).jpeg", mimeType: "image/jpeg")
            }
            return data
        case let .editReview(_, menuId, score, comment, taste, price, foodComposition, images):
            let data = MultipartFormData()
            data.append("\(menuId)".data(using: .utf8)!, withName: "menu_id", mimeType: "text/plain")
            data.append("\(Int(score))".data(using: .utf8)!, withName: "score", mimeType: "text/plain")
            if let comment = comment { data.append(comment.data(using: .utf8)!, withName: "comment", mimeType: "text/plain") }
            data.append(taste.data(using: .utf8)!, withName: "taste", mimeType: "text/plain")
            data.append(price.data(using: .utf8)!, withName: "price", mimeType: "text/plain")
            data.append(foodComposition.data(using: .utf8)!, withName: "food_composition", mimeType: "text/plain")
            if let images = images {
                for (index, image) in images.enumerated() {
                    data.append(image, withName: "images", fileName: "image_\(index).jpeg", mimeType: "image/jpeg")
                }
            }
            return data
        case let .submitPost(boardId, title, content, images,anonymous):
            let data = MultipartFormData()
            data.append("\(boardId)".data(using: .utf8)!, withName: "board_id", mimeType: "text/plain")
            data.append("\(title)".data(using: .utf8)!, withName: "title", mimeType: "text/plain")
            data.append(content.data(using: .utf8)!, withName: "content", mimeType: "text/plain")
            data.append("\(anonymous)".data(using: .utf8)!,withName: "anonymous",mimeType: "text/plain")
            for (index, image) in images.enumerated() {
                data.append(image, withName: "images", fileName: "image_\(index).jpeg", mimeType: "image/jpeg")
            }
            return data
        case let .editPost(_, boardId, title, content, images,anonymous):
            let data = MultipartFormData()
            data.append("\(boardId)".data(using: .utf8)!, withName: "board_id", mimeType: "text/plain")
            data.append("\(title)".data(using: .utf8)!, withName: "title", mimeType: "text/plain")
            data.append(content.data(using: .utf8)!, withName: "content", mimeType: "text/plain")
            data.append("\(anonymous)".data(using: .utf8)!,withName: "anonymous",mimeType: "text/plain")
            for (index, image) in images.enumerated() {
                data.append(image, withName: "images", fileName: "image_\(index).jpeg", mimeType: "image/jpeg")
            }
            return data
        default:
            return nil
        }
    }
}
