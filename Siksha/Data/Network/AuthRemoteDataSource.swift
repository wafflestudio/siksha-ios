//
//  AuthRemoteDataSource.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import Alamofire
import Foundation

protocol AuthRemoteDataSource {
    func login(provider: LoginProvider, token: String) async throws -> AuthTokenResponseDTO
    func loginForTest() async throws -> AuthTokenResponseDTO
    func refreshAccessToken(_ accessToken: String) async throws -> AuthTokenResponseDTO
}

final class AuthRemoteDataSourceImpl: AuthRemoteDataSource {
    func login(provider: LoginProvider, token: String) async throws -> AuthTokenResponseDTO {
        try await AF
            .request(SikshaAPI.getAccessToken(token: token, endPoint: provider.rawValue))
            .validate()
            .serializingDecodable(AuthTokenResponseDTO.self)
            .value
    }

    func loginForTest() async throws -> AuthTokenResponseDTO {
        try await AF
            .request(SikshaAPI.testLogin)
            .validate()
            .serializingDecodable(AuthTokenResponseDTO.self)
            .value
    }

    func refreshAccessToken(_ accessToken: String) async throws -> AuthTokenResponseDTO {
        var request = try SikshaAPI.refreshAccessToken(token: accessToken).asURLRequest()
        request.setToken(token: accessToken)

        return try await AF
            .request(request)
            .validate()
            .serializingDecodable(AuthTokenResponseDTO.self)
            .value
    }
}
