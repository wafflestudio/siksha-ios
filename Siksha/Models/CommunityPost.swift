//
//  Post.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/09/09.
//

import Foundation

class CommunityPost: Identifiable {
    let id: UUID = UUID()
    let title: String
    let content: String
    let userName: String
    let boardName: String
    let createdAt: Date = Date()
    let isLiked: Bool
    let likeCount: Int
    let replyCount: Int
    var images: [String] = []
    private(set) lazy var comments = [Comment]()
    
    init(title: String, content: String, userName: String, boardName: String, isLiked: Bool, likeCount: Int, replyCount: Int) {
        self.title = title
        self.content = content
        self.userName = userName
        self.boardName = boardName
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.replyCount = replyCount
    }
    
    func loadComments() {
        // 서버와 연결 필요

        comments.append(Comment(userName: "abcd", content: "댓글 댓글 댓글 댓글", createdAt: "23/09/06", likeCount: 0, isLiked: false))
        comments.append(Comment(userName: "abc", content: "댓글2 댓글2 댓글2 댓글2", createdAt: "23/09/06", likeCount: 3, isLiked: false))
        comments.append(Comment(userName: "abcde", content: "댓글3 댓글3 댓글3 댓글3", createdAt: "23/09/06", likeCount: 1, isLiked: false))
    }
}

