//
//  Comment.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/09/09.
//

import Foundation

struct Comment: Identifiable {
    var id = UUID()
    
    var userName: String
    var content: String
    var createdAt: String
    var likeCount: Int
    var isLiked: Bool
}
