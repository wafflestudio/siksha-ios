//
//  Post.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/09/09.
//

import Foundation

class Post: Object {
    var id: Int
    var userId: Int
    var createdAt: Date
    var title: String
    var content: String
    
    private(set) lazy var comments = [Comment]()
    
    func loadComments() {
        // 서버와 연결 필요

        comments.append(Comment(id:1, userId: 1, createdAt: Date(), content: "댓글 댓글 댓글 댓글"))
        comments.append(Comment(id:2, userId: 2, createdAt: Date(), content: "댓글2 댓글2 댓글2 댓글2"))
        comments.append(Comment(id:3, userId: 3, createdAt: Date(), content: "댓글3 댓글3 댓글3 댓글3"))
    }
}

