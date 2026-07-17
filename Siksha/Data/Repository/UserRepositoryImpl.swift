//
//  UserRepositoryImpl.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

final class UserRepositoryImpl: UserRepositoryProtocol {
    private let remote: UserRemoteDataSource

    init(remote: UserRemoteDataSource) {
        self.remote = remote
    }

    func fetchCurrentUser() async throws -> User {
        try await remote.fetchCurrentUser().toDomain()
    }

    func updateProfile(
        nickname: String?,
        image: Data?,
        changeToDefaultImage: Bool
    ) async throws -> User {
        try await remote
            .updateProfile(
                nickname: nickname,
                image: image,
                changeToDefaultImage: changeToDefaultImage
            )
            .toDomain()
    }

    func submitVOC(comment: String, platform: String) async throws {
        try await remote.submitVOC(comment: comment, platform: platform)
    }

    func deleteAccount() async throws {
        try await remote.deleteAccount()
    }
}

private extension UserDTO {
    func toDomain() -> User {
        User(
            id: id,
            type: type,
            identity: identity,
            nickname: nickname,
            profileUrl: profileUrl,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
