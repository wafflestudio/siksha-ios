//
//  Community.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/18.
//

import Foundation

struct Board: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case name
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    let id: Int
    let type: Int
    let name: String
    let description: String
    let createdAt: Date
    let updatedAt: Date
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.type = try container.decode(Int.self, forKey: .type)
        self.name = try container.decode(String.self, forKey: .name)
        self.description = try container.decode(String.self, forKey: .description)
        self.createdAt = try container.decodeDate(key: .createdAt)
        self.updatedAt = try container.decodeDate(key: .updatedAt)
    }
}

struct PostsPage: Decodable {
    enum CodingKeys: String, CodingKey {
        case posts = "result"
        case totalCount = "total_count"
        case hasNext = "has_next"
    }
    
    let posts: [Post]
    let totalCount: Int
    let hasNext: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.posts = try container.decode([Post].self, forKey: .posts)
        self.totalCount = try container.decode(Int.self, forKey: .totalCount)
        self.hasNext = try container.decode(Bool.self, forKey: .hasNext)
    }
}

struct Post: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case boardId = "board_id"
        case nickname = "nickname"
        case title
        case content
        case available
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case etc
        case likeCnt = "like_cnt"
        case commentCnt = "comment_cnt"
        case isLiked = "is_liked"
        case anonymous
        case isMine = "is_mine"
    }
    
    let id: Int
    let boardId: Int
    let nickname: String?
    let title: String
    let content: String
    let available: Bool
    let createdAt: Date
    let updatedAt: Date
    let likeCnt: Int
    let commentCnt: Int
    let isLiked: Bool
    let anonymous: Bool
    let isMine: Bool
    var images: [String]?
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.boardId = try container.decode(Int.self, forKey: .boardId)
        self.nickname = try container.decode(String?.self, forKey: .nickname)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        self.available = try container.decode(Bool.self, forKey: .available)
        self.createdAt = try container.decodeDate(key: .createdAt)
        self.updatedAt = try container.decodeDate(key: .updatedAt)
        self.likeCnt = try container.decode(Int.self, forKey: .likeCnt)
        self.commentCnt = try container.decode(Int.self, forKey: .commentCnt)
        self.isLiked = try container.decode(Bool.self, forKey: .isLiked)
        self.anonymous = try container.decode(Bool.self, forKey: .anonymous)
        self.isMine = try container.decode(Bool.self, forKey: .isMine)

        let etc = try container.decodeIfPresent([String: [String]].self, forKey: .etc)
        images = etc?["images"] ?? nil
    }
    
    init() {
        self.id = 0
        self.boardId = 0
        self.nickname = ""
        self.title = ""
        self.content = ""
        self.available = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.likeCnt = 0
        self.commentCnt = 0
        self.isLiked = false
        self.anonymous = false
        self.isMine = false
    }
}
struct SubmitPostResponse:Codable{
    var board_id: Int
    var title : String
    var content: String
    var created_at: String
    var updated_at: String
    var id: Int
    var available: Bool
    var like_cnt: Int
    var comment_cnt: Int
    var is_liked: Bool
    var anonymous: Bool
    var is_mine: Bool
}


struct CommentsPage: Decodable {
    enum CodingKeys: String, CodingKey {
        case comments = "result"
        case totalCount = "total_count"
        case hasNext = "has_next"
    }
    
    let comments: [Comment]
    let totalCount: Int
    let hasNext: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.comments = try container.decode([Comment].self, forKey: .comments)
        self.totalCount = try container.decode(Int.self, forKey: .totalCount)
        self.hasNext = try container.decode(Bool.self, forKey: .hasNext)
    }
}


struct Comment: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case postId = "post_id"
        case content
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case nickname = "nickname"
        case available
        case likeCnt = "like_cnt"
        case isLiked = "is_liked"
        case anonymous
        case isMine = "is_mine"
    }
    
    let id: Int
    let postId: Int
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let nickname: String?
    let available: Bool
    let likeCnt: Int
    let isLiked: Bool
    let anonymous: Bool
    let isMine: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        postId = try container.decode(Int.self, forKey: .postId)
        content = try container.decode(String.self, forKey: .content)
        createdAt = try container.decodeDate(key: .createdAt)
        updatedAt = try container.decodeDate(key: .updatedAt)
        nickname = try container.decode(String?.self, forKey: .nickname)
        available = try container.decode(Bool.self, forKey: .available)
        likeCnt = try container.decode(Int.self, forKey: .likeCnt)
        isLiked = try container.decode(Bool.self, forKey: .isLiked)
        anonymous = try container.decode(Bool.self, forKey: .anonymous)
        isMine = try container.decode(Bool.self, forKey: .isMine)
    }
}
struct PostReportResponse: Codable{
    var id: Int
    var reason: String
    var post_id: Int
}
struct CommentReportResponse: Codable{
    var id: Int
    var reason: String
    var comment_id: Int
}
struct TrendingPostsResponse:Decodable {
    var result:[Post]
}
