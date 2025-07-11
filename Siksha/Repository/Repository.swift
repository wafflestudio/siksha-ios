//
//  Repository.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

import Combine
import Foundation

protocol NetworkModuleProtocol {
    func request<T: Decodable>(endpoint: SikshaAPI) -> AnyPublisher<T, AppError>
    func requestWithNoContent(endpoint: SikshaAPI) -> AnyPublisher<Void, AppError>
}

final class Repository: RepositoryProtocol {
    private let networkModule: NetworkModuleProtocol
    init(networkModule: NetworkModuleProtocol) {
        self.networkModule = networkModule
    }
}

extension Repository: CommunityRepositoryProtocol {
    
    func loadBoardList() -> AnyPublisher<[Board], AppError> {
        let endpoint = SikshaAPI.getBoards
        return self.networkModule.request(endpoint: endpoint)
    }
    func submitPost(boardId:Int,title: String, content: String, images: [Data],anonymous:Bool) -> AnyPublisher<SubmitPostResponse, AppError> {
        let endpoint = SikshaAPI.submitPost(boardId: boardId, title: title, content: content, images: images,anonymous: anonymous)
        return self.networkModule.request(endpoint:endpoint)
    }
    
    func editPost(postId:Int, boardId:Int,title:String,content:String,images:[Data],anonymous:Bool) ->AnyPublisher<SubmitPostResponse,AppError> {
        let endpoint = SikshaAPI.editPost(postId: postId, boardId: boardId, title: title, content: content, images: images,anonymous: anonymous)
        return self.networkModule.request(endpoint:endpoint)
    }

    
    func loadPostsPage(boardId: Int, page: Int, perPage: Int = 20) -> AnyPublisher<PostsPage, AppError> {
        let endpoint = SikshaAPI.getPosts(boardId: boardId, page: page, perPage: perPage)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func loadTrendingPosts(likes: Int, created_before: Int) -> AnyPublisher<TrendingPostsResponse, AppError> {
        let endpoint = SikshaAPI.getTrendingPosts(likes: likes, created_before: created_before)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func loadMyPostsPage(page: Int, perPage: Int) -> AnyPublisher<PostsPage, AppError> {
        let endpoint = SikshaAPI.getMyposts(page: page, perPage: perPage)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func loadPost(postId: Int) -> AnyPublisher<Post, AppError> {
        let endpoint = SikshaAPI.getPost(postId: postId)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func deletePost(postId: Int) -> AnyPublisher<Void, AppError> {
        let endpoint = SikshaAPI.deletePost(postId: postId)
        return self.networkModule.requestWithNoContent(endpoint: endpoint)
    }
    
    func likePost(postId: Int) -> AnyPublisher<Post, AppError> {
        let endpoint = SikshaAPI.likePost(postId: postId)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func unlikePost(postId: Int) -> AnyPublisher<Post, AppError> {
        let endpoint = SikshaAPI.unlikePost(postId: postId)
        return self.networkModule.request(endpoint: endpoint)
    }

    func loadCommentsPage(postId: Int, page: Int, perPage: Int) -> AnyPublisher<CommentsPage, AppError> {
        let endpoint = SikshaAPI.getComments(postId: postId, page: page, perPage: perPage)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func postComment(postId: Int, content: String,anonymous:Bool) -> AnyPublisher<Comment, AppError> {
        let endpoint = SikshaAPI.submitComment(postId: postId, content: content,anonymous: anonymous)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func editComment(commentId: Int, content: String) -> AnyPublisher<Comment, AppError> {
        let endpoint = SikshaAPI.editComment(commentId: commentId, content: content)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func deleteComment(commentId: Int) -> AnyPublisher<Void, AppError> {
        let endpoint = SikshaAPI.deleteComment(commentId: commentId)
        return self.networkModule.requestWithNoContent(endpoint: endpoint)
    }
    
    func likeComment(commentId: Int) -> AnyPublisher<Comment, AppError> {
        let endpoint = SikshaAPI.likeComment(commentId: commentId)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func unlikeComment(commentId: Int) -> AnyPublisher<Comment, AppError> {
        let endpoint = SikshaAPI.unlikeComment(commentId: commentId)
        return self.networkModule.request(endpoint: endpoint)
    }
    func reportPost(postId: Int, reason: String) -> AnyPublisher<PostReportResponse, AppError> {
        let endpoint = SikshaAPI.reportPost(postId: postId, reason: reason)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func reportComment(commentId: Int, reason: String) -> AnyPublisher<CommentReportResponse, AppError> {
        let endpoint = SikshaAPI.reportComment(commentId: commentId, reason: reason)
        return self.networkModule.request(endpoint: endpoint)

    }
}


extension Repository: UserRepositoryProtocol {
    func loadUserInfo() -> AnyPublisher<User, AppError> {
        let endpoint = SikshaAPI.loadUserInfo
        return self.networkModule.request(endpoint: endpoint)
    }
    func submitVOC(comment: String, platform: String) -> AnyPublisher<Void, AppError> {
        let endpoint = SikshaAPI.submitVOC(comment: comment, platform: platform)
        return self.networkModule.requestWithNoContent(endpoint: endpoint)
    }
    func deleteUser() -> AnyPublisher<Void, AppError> {
        let endpoint = SikshaAPI.deleteUser
        return self.networkModule.requestWithNoContent(endpoint: endpoint)
    }
    
    func updateUserProfile(nickname: String?, image: Data?, changeToDefaultImage: Bool) -> AnyPublisher<User, AppError> {
        let endpoint = SikshaAPI.updateUserProfile(nickname: nickname, image: image, changeToDefaultImage: changeToDefaultImage)
        return self.networkModule.request(endpoint: endpoint)
    }
}
