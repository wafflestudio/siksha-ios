//
//  AuthSessionLocalDataSource.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

protocol AuthSessionLocalDataSource {
    func loadSession() -> AuthSession?
    func saveSession(_ session: AuthSession)
    func clearSession()
}

final class AuthSessionLocalDataSourceImpl: AuthSessionLocalDataSource {
    private enum Key {
        static let accessToken = "accessToken"
        static let tokenExpDate = "tokenExpDate"
        static let appleUserIdentifier = "appleUserIdentifier"
        static let signedInWithApple = "signedInWithApple"
    }

    private let userDefaults: UserDefaults

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func loadSession() -> AuthSession? {
        guard let accessToken = userDefaults.string(forKey: Key.accessToken) else {
            return nil
        }

        let expiresAt = expirationDate()
        let appleUserIdentifier = userDefaults.bool(forKey: Key.signedInWithApple)
            ? userDefaults.string(forKey: Key.appleUserIdentifier)
            : nil

        return AuthSession(
            accessToken: accessToken,
            expiresAt: expiresAt,
            appleUserIdentifier: appleUserIdentifier
        )
    }

    func saveSession(_ session: AuthSession) {
        userDefaults.set(session.accessToken, forKey: Key.accessToken)

        if let expiresAt = session.expiresAt {
            userDefaults.set(expiresAt.timeIntervalSince1970, forKey: Key.tokenExpDate)
        } else {
            userDefaults.removeObject(forKey: Key.tokenExpDate)
        }

        if let appleUserIdentifier = session.appleUserIdentifier {
            userDefaults.set(appleUserIdentifier, forKey: Key.appleUserIdentifier)
            userDefaults.set(true, forKey: Key.signedInWithApple)
        } else {
            userDefaults.removeObject(forKey: Key.appleUserIdentifier)
            userDefaults.set(false, forKey: Key.signedInWithApple)
        }
    }

    func clearSession() {
        userDefaults.removeObject(forKey: Key.accessToken)
        userDefaults.removeObject(forKey: Key.tokenExpDate)
        userDefaults.removeObject(forKey: Key.appleUserIdentifier)
        userDefaults.removeObject(forKey: Key.signedInWithApple)
    }

    private func expirationDate() -> Date? {
        guard let timestamp = userDefaults.object(forKey: Key.tokenExpDate) as? Double else {
            return nil
        }

        return Date(timeIntervalSince1970: timestamp)
    }
}
