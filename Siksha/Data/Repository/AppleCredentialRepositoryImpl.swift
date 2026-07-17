//
//  AppleCredentialRepositoryImpl.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

final class AppleCredentialRepositoryImpl: AppleCredentialRepositoryProtocol {
    private let service: AppleCredentialService

    init(service: AppleCredentialService) {
        self.service = service
    }

    func credentialStatus(for userIdentifier: String) async -> AppleCredentialStatus {
        await service.credentialStatus(for: userIdentifier)
    }
}
