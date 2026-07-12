//
//  AppleCredentialRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

protocol AppleCredentialRepositoryProtocol {
    func credentialStatus(for userIdentifier: String) async -> AppleCredentialStatus
}
