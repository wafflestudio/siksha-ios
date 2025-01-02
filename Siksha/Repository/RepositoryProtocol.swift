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
    func loadBoardList() -> AnyPublisher<[Board], AppError>
    func submitPost(boardId:Int,title:String,content:String,images:[Data],anonymous:Bool) ->AnyPublisher<SubmitPostResponse,AppError>
    func editPost(postId:Int, boardId:Int,title:String,content:String,images:[Data],anonymous:Bool) ->AnyPublisher<SubmitPostResponse,AppError>
    func loadPostsPage(boardId: Int, page: Int, perPage: Int) -> AnyPublisher<PostsPage, AppError>
    func loadTrendingPosts(likes:Int,created_before:Int) -> AnyPublisher<TrendingPostsResponse,AppError>
    func loadMyPostsPage(page: Int, perPage: Int) -> AnyPublisher<PostsPage, AppError>
    func loadPost(postId: Int) -> AnyPublisher<Post, AppError>
    func deletePost(postId: Int) -> AnyPublisher<Void, AppError>
    func likePost(postId: Int) -> AnyPublisher<Post, AppError>
    func unlikePost(postId: Int) -> AnyPublisher<Post, AppError>
    func loadCommentsPage(postId: Int, page: Int, perPage: Int) -> AnyPublisher<CommentsPage, AppError>
    func postComment(postId: Int, content: String,anonymous:Bool) -> AnyPublisher<Comment, AppError>
    func editComment(commentId: Int, content: String) -> AnyPublisher<Comment, AppError>
    func deleteComment(commentId: Int) -> AnyPublisher<Void, AppError>
    func likeComment(commentId: Int) -> AnyPublisher<Comment, AppError>
    func unlikeComment(commentId: Int) -> AnyPublisher<Comment, AppError>
    func reportPost(postId:Int,reason:String)->AnyPublisher<PostReportResponse,AppError>
    func reportComment(commentId:Int,reason:String)->AnyPublisher<CommentReportResponse,AppError>
    
}

protocol UserRepositoryProtocol {
    func loadUserInfo() -> AnyPublisher<User, AppError>
    func updateUserProfile(nickname: String?, image: Data?, changeToDefaultImage: Bool) -> AnyPublisher<User, AppError>
    func submitVOC(comment: String, platform: String) -> AnyPublisher<Void, AppError>
    func deleteUser() -> AnyPublisher<Void, AppError>
}
