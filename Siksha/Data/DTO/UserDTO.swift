//
//  UserDTO.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

struct UserDTO: Decodable, Sendable {
    let id: Int
    let type: String
    let identity: String
    let nickname: String?
    let profileUrl: String?
    let createdAt: Date
    let updatedAt: Date
}
