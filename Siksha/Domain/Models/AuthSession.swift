//
//  AuthSession.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

struct AuthSession: Sendable {
    let accessToken: String
    let expiresAt: Date?
    let appleUserIdentifier: String?

    init(
        accessToken: String,
        expiresAt: Date?,
        appleUserIdentifier: String? = nil
    ) {
        self.accessToken = accessToken
        self.expiresAt = expiresAt
        self.appleUserIdentifier = appleUserIdentifier
    }

    func isExpired(asOf date: Date = Date()) -> Bool {
        guard let expiresAt else {
            return false
        }

        return expiresAt <= date
    }

    func needsRefresh(
        asOf date: Date = Date(),
        refreshWindow: TimeInterval = 15_552_000
    ) -> Bool {
        guard let expiresAt, !isExpired(asOf: date) else {
            return false
        }

        return DateInterval(start: date, end: expiresAt).duration < refreshWindow
    }
}
