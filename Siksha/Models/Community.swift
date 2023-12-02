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
        case title
        case content
        case available
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case etc
        case likeCnt = "like_cnt"
        case commentCnt = "comment_cnt"
        case isLiked = "is_liked"
    }
    
    let id: Int
    let boardId: Int
    let title: String
    let content: String
    let available: Bool
    let createdAt: Date
    let updatedAt: Date
    let likeCnt: Int
    let commentCnt: Int
    let isLiked: Bool
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.boardId = try container.decode(Int.self, forKey: .boardId)
        self.title = try container.decode(String.self, forKey: .title)
        self.content = try container.decode(String.self, forKey: .content)
        self.available = try container.decode(Bool.self, forKey: .available)
        self.createdAt = try container.decodeDate(key: .createdAt)
        self.updatedAt = try container.decodeDate(key: .updatedAt)
        self.likeCnt = try container.decode(Int.self, forKey: .likeCnt)
        self.commentCnt = try container.decode(Int.self, forKey: .commentCnt)
        self.isLiked = try container.decode(Bool.self, forKey: .isLiked)
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
        self.posts = try container.decode([Post].self, forKey: .posts)
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
        case userId = "user_id"
        case available
        case likeCnt = "like_cnt"
        case isLiked = "is_liked"
    }
    
    let id: Int
    let postId: Int
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let userId: Int
    let available: Bool
    let likeCnt: Int
    let isLiked: Bool

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        postId = try container.decode(Int.self, forKey: .postId)
        content = try container.decode(String.self, forKey: .content)
        createdAt = try container.decodeDate(key: .createdAt)
        updatedAt = try container.decodeDate(key: .updatedAt)
        userId = try container.decode(Int.self, forKey: .userId)
        available = try container.decode(Bool.self, forKey: .available)
        likeCnt = try container.decode(Int.self, forKey: .likeCnt)
        isLiked = try container.decode(Bool.self, forKey: .isLiked)
    }
}
