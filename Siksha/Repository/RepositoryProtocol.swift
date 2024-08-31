//
//  RepositoryProtocol.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

import Foundation
import Combine

protocol RepositoryProtocol: CommunityRepositoryProtocol, UserRepositoryProtocol {

}

protocol CommunityRepositoryProtocol {
    func loadBoardList() -> AnyPublisher<[Board], Error>
    func submitPost(boardId:Int,title:String,content:String,images:[Data],anonymous:Bool) ->AnyPublisher<SubmitPostResponse,Error>
    func editPost(postId:Int, boardId:Int,title:String,content:String,images:[Data],anonymous:Bool) ->AnyPublisher<SubmitPostResponse,Error>
    func loadPostsPage(boardId: Int, page: Int, perPage: Int) -> AnyPublisher<PostsPage, Error>
    func loadTrendingPosts(likes:Int,created_before:Int) -> AnyPublisher<TrendingPostsResponse,Error>
    func loadMyPostsPage(page: Int, perPage: Int) -> AnyPublisher<PostsPage, Error>
    func loadPost(postId: Int) -> AnyPublisher<Post, Error>
    func deletePost(postId: Int) -> AnyPublisher<Void, Error>
    func likePost(postId: Int) -> AnyPublisher<Post, Error>
    func unlikePost(postId: Int) -> AnyPublisher<Post, Error>
    func loadCommentsPage(postId: Int, page: Int, perPage: Int) -> AnyPublisher<CommentsPage, Error>
    func postComment(postId: Int, content: String,anonymous:Bool) -> AnyPublisher<Comment, Error>
    func editComment(commentId: Int, content: String) -> AnyPublisher<Comment, Error>
    func deleteComment(commentId: Int) -> AnyPublisher<Void, Error>
    func likeComment(commentId: Int) -> AnyPublisher<Comment, Error>
    func unlikeComment(commentId: Int) -> AnyPublisher<Comment, Error>
    func reportPost(postId:Int,reason:String)->AnyPublisher<PostReportResponse,Error>
    func reportComment(commentId:Int,reason:String)->AnyPublisher<CommentReportResponse,Error>
    
}

protocol UserRepositoryProtocol {
    func loadUserInfo() -> AnyPublisher<User, Error>
    func updateUserProfile(nickname: String?, image: Data?, changeToDefaultImage: Bool) -> AnyPublisher<User, Error>
    func submitVOC(comment: String, platform: String) -> AnyPublisher<Void, any Error>
    func deleteUser() -> AnyPublisher<Void, Error>
}
