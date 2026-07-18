//
//  AppVersionDTO.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

struct AppVersionLookupResponseDTO: Decodable, Sendable {
    let results: [AppVersionResultDTO]
}

struct AppVersionResultDTO: Decodable, Sendable {
    let version: String
}
