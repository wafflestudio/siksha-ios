//
//  RepositoryProtocol.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

import Foundation
import Combine

protocol RepositoryProtocol: CommunityRepositoryProtocol {

}

protocol CommunityRepositoryProtocol {
    func loadBoardList() -> AnyPublisher<[Board], Error>
    func submitPost(boardId:Int,title:String,content:String,images:[Data]) ->AnyPublisher<SubmitPostResponse,Error>
    func loadPostsPage(boardId: Int, page: Int, perPage: Int) -> AnyPublisher<PostsPage, Error>
    func loadPost(postId: Int) -> AnyPublisher<Post, Error>
    func likePost(postId: Int) -> AnyPublisher<Post, Error>
    func unlikePost(postId: Int) -> AnyPublisher<Post, Error>
    func loadComments(postId: Int) -> AnyPublisher<Post, Error>
    func postComment(postId: Int, content: String) -> AnyPublisher<Comment, Error>
    func editComment(commentId: Int, content: String) -> AnyPublisher<Comment, Error>
    func deleteComment(commentId: Int) -> AnyPublisher<Void, Error>
    func likeComment(commentId: Int) -> AnyPublisher<Comment, Error>
    func unlikeComment(commentId: Int) -> AnyPublisher<Comment, Error>
}
