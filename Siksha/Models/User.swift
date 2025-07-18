//
//  User.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/12/04.
//

import Foundation

struct User: Decodable {
    enum CodingKeys: String, CodingKey {
        case id
        case type
        case identity
        case nickname
        case profileUrl = "profile_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    let id: Int
    let type: String
    let identity: String
    let nickname: String?
    let profileUrl: String?
    let createdAt: Date
    let updatedAt: Date
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(Int.self, forKey: .id)
        self.type = try container.decode(String.self, forKey: .type)
        self.identity = try container.decode(String.self, forKey: .identity)
        self.nickname = try container.decodeIfPresent(String.self, forKey: .nickname)
        self.profileUrl = try container.decodeIfPresent(String.self, forKey: .profileUrl)
        self.createdAt = try container.decodeDate(key: .createdAt)
        self.updatedAt = try container.decodeDate(key: .updatedAt)
    }
}
