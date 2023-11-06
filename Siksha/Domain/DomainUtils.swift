//
//  DomainUtils.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/26.
//

import Foundation

extension KeyedDecodingContainer {
    func decodeDate(key: KeyedDecodingContainer<K>.Key) throws -> Date {
        let dateString = try self.decode(String.self, forKey: key)
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        
        formatter.dateFormat = "yyyy-MM-dd'T'hh:mm:ss"
        
        if let date = formatter.date(from: dateString) {
            return date
        }
        
        let isoFormatter = ISO8601DateFormatter()
        if let date = isoFormatter.date(from: dateString) {
            return date
        }
        
        throw NetworkError.decodingError
    }
}
