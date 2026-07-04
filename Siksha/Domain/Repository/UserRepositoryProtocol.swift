//
//  UserRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Foundation

protocol UserRepositoryProtocol {
    func fetchCurrentUser() async throws -> User
    func updateProfile(
        nickname: String?,
        image: Data?,
        changeToDefaultImage: Bool
    ) async throws -> User
    func submitVOC(comment: String, platform: String) async throws
    func deleteAccount() async throws
}
