//
//  AppleCredentialService.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import AuthenticationServices

protocol AppleCredentialService {
    func credentialStatus(for userIdentifier: String) async -> AppleCredentialStatus
}

final class AppleCredentialServiceImpl: AppleCredentialService {
    private let provider: ASAuthorizationAppleIDProvider

    init(provider: ASAuthorizationAppleIDProvider = ASAuthorizationAppleIDProvider()) {
        self.provider = provider
    }

    func credentialStatus(for userIdentifier: String) async -> AppleCredentialStatus {
        await withCheckedContinuation { continuation in
            provider.getCredentialState(forUserID: userIdentifier) { credentialState, error in
                guard error == nil else {
                    continuation.resume(returning: .unknown)
                    return
                }

                switch credentialState {
                case .authorized:
                    continuation.resume(returning: .authorized)
                case .revoked:
                    continuation.resume(returning: .revoked)
                case .notFound:
                    continuation.resume(returning: .notFound)
                default:
                    continuation.resume(returning: .unknown)
                }
            }
        }
    }
}
