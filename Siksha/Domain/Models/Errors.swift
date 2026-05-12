//
//  Errors.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/26.
//

enum NetworkError: Error {
    case decodingError
    case conflict            // 409 Conflict
    case apiError(message: String, code: String) // Handle API errors
}

