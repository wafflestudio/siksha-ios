//
//  AppVersionDTO.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

struct AppVersionLookupResponseDTO: Decodable {
    let results: [AppVersionResultDTO]
}

struct AppVersionResultDTO: Decodable {
    let version: String
}
