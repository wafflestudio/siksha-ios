//
//  JWTTokenDecoder.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

struct JWTTokenDecoder {
    func expirationDate(from token: String) -> Date? {
        guard let exp = decodePayload(token)["exp"] as? Double else {
            return nil
        }

        return Date(timeIntervalSince1970: exp)
    }

    private func decodePayload(_ token: String) -> [String: Any] {
        let segments = token.components(separatedBy: ".")
        guard segments.count == 3 else {
            return [:]
        }

        guard let data = base64URLDecode(segments[1]),
              let json = try? JSONSerialization.jsonObject(with: data),
              let payload = json as? [String: Any] else {
            return [:]
        }

        return payload
    }

    private func base64URLDecode(_ value: String) -> Data? {
        var base64 = value
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let remainder = base64.count % 4
        if remainder > 0 {
            base64.append(String(repeating: "=", count: 4 - remainder))
        }

        return Data(base64Encoded: base64, options: .ignoreUnknownCharacters)
    }
}
