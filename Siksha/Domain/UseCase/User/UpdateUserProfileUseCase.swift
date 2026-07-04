//
//  UpdateUserProfileUseCase.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

protocol UpdateUserProfileUseCase {
    func execute(
        nickname: String?,
        image: Data?,
        changeToDefaultImage: Bool
    ) async throws -> User
}

final class DefaultUpdateUserProfileUseCase: UpdateUserProfileUseCase {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute(
        nickname: String?,
        image: Data?,
        changeToDefaultImage: Bool
    ) async throws -> User {
        try await repository.updateProfile(
            nickname: nickname,
            image: image,
            changeToDefaultImage: changeToDefaultImage
        )
    }
}
