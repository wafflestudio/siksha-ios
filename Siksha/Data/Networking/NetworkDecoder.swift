//
//  NetworkDecoder.swift
//  Siksha
//
//  Created by Jihyeon on 2/13/26.
//

import Foundation

enum NetworkDecoder {
    static func make() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        decoder.dateDecodingStrategy = .custom({ (decoder) -> Date in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            let formatter = ISO8601DateFormatter()
            
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            if let date = formatter.date(from: dateString) {
                return date
            }
            
            throw AppError.networkError("failed to decode date")
        })


        return decoder
    }
}

//2026-02-23T06:30:11.001Z
