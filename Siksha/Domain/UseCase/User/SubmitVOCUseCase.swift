//
//  SubmitVOCUseCase.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

protocol SubmitVOCUseCase {
    func execute(comment: String, platform: String) async throws
}

final class DefaultSubmitVOCUseCase: SubmitVOCUseCase {
    private let repository: UserRepositoryProtocol

    init(repository: UserRepositoryProtocol) {
        self.repository = repository
    }

    func execute(comment: String, platform: String) async throws {
        try await repository.submitVOC(comment: comment, platform: platform)
    }
}
