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
        self.updatedAt = try container.decodeDate(key: .createdAt)
    }
}
