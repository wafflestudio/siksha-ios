//
//  UserRemoteDataSource.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Alamofire
import Foundation

protocol UserRemoteDataSource {
    func fetchCurrentUser() async throws -> UserDTO
    func updateProfile(
        nickname: String?,
        image: Data?,
        changeToDefaultImage: Bool
    ) async throws -> UserDTO
    func submitVOC(comment: String, platform: String) async throws
    func deleteAccount() async throws
}

final class UserRemoteDataSourceImpl: UserRemoteDataSource {
    func fetchCurrentUser() async throws -> UserDTO {
        try await AF
            .request(SikshaAPI.getUserInfo)
            .validate()
            .serializingDecodable(UserDTO.self, decoder: NetworkDecoder.make())
            .value
    }

    func updateProfile(
        nickname: String?,
        image: Data?,
        changeToDefaultImage: Bool
    ) async throws -> UserDTO {
        let endpoint = SikshaAPI.updateUserProfile(
            nickname: nickname,
            image: image,
            changeToDefaultImage: changeToDefaultImage
        )

        return try await AF
            .upload(multipartFormData: endpoint.multipartFormData!, with: endpoint)
            .validate()
            .serializingDecodable(UserDTO.self, decoder: NetworkDecoder.make())
            .value
    }

    func submitVOC(comment: String, platform: String) async throws {
        try await validateNoContentRequest(AF.request(SikshaAPI.submitVOC(comment: comment, platform: platform)))
    }

    func deleteAccount() async throws {
        try await validateNoContentRequest(AF.request(SikshaAPI.deleteUser))
    }

    private func validateNoContentRequest(_ request: DataRequest) async throws {
        _ = try await request
            .validate()
            .serializingData(emptyResponseCodes: [200, 201, 204])
            .value
    }
}
