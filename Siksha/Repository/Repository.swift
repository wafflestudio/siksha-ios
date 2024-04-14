//
//  Repository.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

import Combine
import Foundation

protocol NetworkModuleProtocol {
    func request<T: Decodable>(endpoint: SikshaAPI) -> AnyPublisher<T, Error>
    func requestWithNoContent(endpoint: SikshaAPI) -> AnyPublisher<Void, Error>
}

final class Repository: RepositoryProtocol {
    private let networkModule: NetworkModuleProtocol
    init(networkModule: NetworkModuleProtocol) {
        self.networkModule = networkModule
    }
}

extension Repository: CommunityRepositoryProtocol {
    func loadBoardList() -> AnyPublisher<[Board], Error> {
        let endpoint = SikshaAPI.getBoards
        return self.networkModule.request(endpoint: endpoint)
    }
    func submitPost(boardId:Int,title: String, content: String, images: [Data],anonymous:Bool) -> AnyPublisher<SubmitPostResponse, Error> {
        let endpoint = SikshaAPI.submitPost(boardId: boardId, title: title, content: content, images: images,anonymous: anonymous)
        return self.networkModule.request(endpoint:endpoint)
    }
    
    func loadPostsPage(boardId: Int, page: Int, perPage: Int = 20) -> AnyPublisher<PostsPage, Error> {
        let endpoint = SikshaAPI.getPosts(boardId: boardId, page: page, perPage: perPage)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func loadMyPostsPage(page: Int, perPage: Int) -> AnyPublisher<PostsPage, Error> {
        let endpoint = SikshaAPI.getMyposts(page: page, perPage: perPage)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func loadPost(postId: Int) -> AnyPublisher<Post, Error> {
        let endpoint = SikshaAPI.getPost(postId: postId)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func deletePost(postId: Int) -> AnyPublisher<Void, Error> {
        let endpoint = SikshaAPI.deletePost(postId: postId)
        return self.networkModule.requestWithNoContent(endpoint: endpoint)
    }
    
    func likePost(postId: Int) -> AnyPublisher<Post, Error> {
        let endpoint = SikshaAPI.likePost(postId: postId)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func unlikePost(postId: Int) -> AnyPublisher<Post, Error> {
        let endpoint = SikshaAPI.unlikePost(postId: postId)
        return self.networkModule.request(endpoint: endpoint)
    }

    func loadCommentsPage(postId: Int, page: Int, perPage: Int) -> AnyPublisher<CommentsPage, Error> {
        let endpoint = SikshaAPI.getComments(postId: postId, page: page, perPage: perPage)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func postComment(postId: Int, content: String,anonymous:Bool) -> AnyPublisher<Comment, Error> {
        let endpoint = SikshaAPI.submitComment(postId: postId, content: content,anonymous: anonymous)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func editComment(commentId: Int, content: String) -> AnyPublisher<Comment, Error> {
        let endpoint = SikshaAPI.editComment(commentId: commentId, content: content)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func deleteComment(commentId: Int) -> AnyPublisher<Void, Error> {
        let endpoint = SikshaAPI.deleteComment(commentId: commentId)
        return self.networkModule.requestWithNoContent(endpoint: endpoint)
    }
    
    func likeComment(commentId: Int) -> AnyPublisher<Comment, Error> {
        let endpoint = SikshaAPI.likeComment(commentId: commentId)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func unlikeComment(commentId: Int) -> AnyPublisher<Comment, Error> {
        let endpoint = SikshaAPI.unlikeComment(commentId: commentId)
        return self.networkModule.request(endpoint: endpoint)
    }
    func reportPost(postId: Int, reason: String) -> AnyPublisher<PostReportResponse, Error> {
        let endpoint = SikshaAPI.reportPost(postId: postId, reason: reason)
        return self.networkModule.request(endpoint: endpoint)
    }
    
    func reportComment(commentId: Int, reason: String) -> AnyPublisher<CommentReportResponse, Error> {
        let endpoint = SikshaAPI.reportComment(commentId: commentId, reason: reason)
        return self.networkModule.request(endpoint: endpoint)

    }
}


extension Repository: UserRepositoryProtocol {
    func loadUserInfo() -> AnyPublisher<User, Error> {
        let endpoint = SikshaAPI.loadUserInfo
        return self.networkModule.request(endpoint: endpoint)
    }
    func submitVOC(comment: String, platform: String) -> AnyPublisher<Void, any Error> {
        let endpoint = SikshaAPI.submitVOC(comment: comment, platform: platform)
        return self.networkModule.requestWithNoContent(endpoint: endpoint)
    }
    func deleteUser() -> AnyPublisher<Void, any Error> {
        let endpoint = SikshaAPI.deleteUser
        return self.networkModule.requestWithNoContent(endpoint: endpoint)
    }
    
    func updateUserProfile(nickname: String?, image: Data?) -> AnyPublisher<User, any Error> {
        let endpoint = SikshaAPI.updateUserProfile(nickname: nickname, image: image)
        return self.networkModule.request(endpoint: endpoint)
    }
}
