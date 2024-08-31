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
        
        print("token:")
        print(UserDefaults.standard.string(forKey: "accessToken"))
        
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
    
    // Community
    case getBoards
    case getPosts(boardId: Int, page: Int, perPage: Int)
    case getTrendingPosts(likes:Int,created_before:Int)
    case getMyposts(page: Int, perPage: Int)
    case getPost(postId: Int)
    case deletePost(postId: Int)
    case likePost(postId: Int)
    case unlikePost(postId: Int)
    case getComments(postId: Int, page: Int, perPage: Int)
    case submitComment(postId: Int, content: String,anonymous: Bool)
    case editComment(commentId: Int, content: String)
    case deleteComment(commentId: Int)
    case likeComment(commentId: Int)
    case unlikeComment(commentId: Int)
    case submitPost(boardId:Int,title:String,content:String,images:[Data],anonymous:Bool)
    case editPost(postId: Int, boardId:Int,title:String,content:String,images:[Data],anonymous:Bool)

    case reportPost(postId:Int,reason:String)
    case reportComment(commentId:Int,reason:String)
    // User
    case loadUserInfo
    case updateUserProfile(nickname: String?, image: Data?, changeToDefaultImage: Bool)
    case deleteUser

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
        case .getBoards:
            return .get
        case .getPosts:
            return .get
        case .getTrendingPosts:
            return .get
        case .getMyposts:
            return .get
        case .getPost:
            return .get
        case .submitPost:
            return .post
        case .editPost:
            return .patch
        case .deletePost:
            return .delete
        case .likePost:
            return .post
        case .unlikePost:
            return .post
        case .getComments:
            return .get
        case .submitComment:
            return .post
        case .editComment:
            return .patch
        case .deleteComment:
            return .delete
        case .likeComment:
            return .post
        case .unlikeComment:
            return .post

        case .submitPost:
            return .post
        case .reportPost:
            return .post
        case .reportComment:
            return .post
        case .loadUserInfo:
            return .get
        case .updateUserProfile:
            return .patch
        case .deleteUser:
            return .delete
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
        case .getBoards:
            return "/community/boards"
        case .getPosts:
            return "/community/posts"
        case .getTrendingPosts:
            return "/community/posts/popular/trending"
        case .getMyposts:
            return "/community/posts/me"
        case .submitPost:
            return "/community/posts"
        case .editPost(postId: let postId, boardId: _, title: _, content: _, images: _, anonymous: _):
            return "/community/posts/\(postId)"
        case let .getPost(postId):
            return "/community/posts/\(postId)"
        case let .deletePost(postId):
            return "/community/posts/\(postId)"
        case let .likePost(postId):
            return "/community/posts/\(postId)/like"
        case let .unlikePost(postId):
            return "/community/posts/\(postId)/unlike"
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
        case let .reportPost(postId, _):
            return "/community/posts/\(postId)/report"
        case let .reportComment(commentId, _):
            return "/community/comments/\(commentId)/report"
        case .loadUserInfo:
            return "/auth/me/image"
        case .updateUserProfile:
            return "/auth/me/image/profile"
        case .deleteUser:
            return "/auth"
        }
    }
    
    var parameters: [String: Any]? {
        switch self {
        case let .getMenus(startDate, endDate, noMenuHide):
            return ["start_date": startDate, "end_date": endDate, "except_empty": noMenuHide]
        case let .getReviews(menuId, page, perPage):
            return ["menu_id": menuId, "page": page, "per_page": perPage]
        case let .getScoreDistribution(menuId):
            return ["menu_id": menuId]
        case let .getCommentRecommendation(score):
            return ["score": score]
        case let .submitReview(menuId, score, comment):
            return ["menu_id": menuId, "score": score, "comment": comment]
        case let .getReviewImages(menuId, page, perPage, comment, etc):
            return ["menu_id": menuId, "page": page, "per_page": perPage, "comment": comment, "etc": etc]
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
        case let .editPost(postId, boardId, title, content, images, anonymous):
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
        default:
            return nil
        }
    }
    
    var multiPartFormDataNeeded: Bool {
        switch self {
        case .submitReviewImages:
            return true
        case .submitPost:
            return true
        case .updateUserProfile:
            return true
        case .editPost:
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
