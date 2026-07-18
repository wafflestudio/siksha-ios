//
//  MenuLikeStatusDTO.swift
//  Siksha
//
//  Created by Codex on 6/24/26.
//

struct MenuLikeStatusDTO: Decodable, Sendable {
    let menuId: Int
    let isLiked: Bool
    let likeCount: Int

    enum CodingKeys: String, CodingKey {
        case menuId = "id"
        case isLiked = "is_liked"
        case likeCount = "like_cnt"
    }
}
