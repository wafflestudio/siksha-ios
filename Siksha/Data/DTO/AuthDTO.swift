//
//  AuthDTO.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

struct AuthTokenResponseDTO: Decodable {
    let accessToken: String

    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}
