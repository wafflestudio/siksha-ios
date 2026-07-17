//
//  FirebaseMessagingService.swift
//  Siksha
//
//  Created by Codex on 7/13/26.
//

import FirebaseMessaging
import Foundation

private enum FirebaseMessagingServiceError: LocalizedError {
    case missingToken

    var errorDescription: String? {
        "Firebase Messaging did not return a token."
    }
}

final class FirebaseMessagingServiceImpl: PushMessagingTokenServiceProtocol {
    func setAPNSToken(_ token: Data) {
        Messaging.messaging().apnsToken = token
    }

    func fetchToken() async throws -> String {
        try await withCheckedThrowingContinuation { continuation in
            Messaging.messaging().token { token, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let token {
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(throwing: FirebaseMessagingServiceError.missingToken)
                }
            }
        }
    }

    func deleteToken() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            Messaging.messaging().deleteToken { error in
                if let error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: ())
                }
            }
        }
    }
}
