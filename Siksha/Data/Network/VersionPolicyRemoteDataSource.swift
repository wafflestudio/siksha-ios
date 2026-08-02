//
//  VersionPolicyRemoteDataSource.swift
//  Siksha
//

import Alamofire
import Foundation

protocol VersionPolicyRemoteDataSource: Sendable {
    func fetchMinimumSupportedVersion() async throws -> VersionPolicyDTO
}

final class VersionPolicyRemoteDataSourceImpl: VersionPolicyRemoteDataSource {
    func fetchMinimumSupportedVersion() async throws -> VersionPolicyDTO {
        var request = try SikshaAPI.getMinimumIOSVersion.asURLRequest()
        request.timeoutInterval = 5

        return
            try await AF
            .request(request)
            .validate()
            .serializingDecodable(VersionPolicyDTO.self, decoder: NetworkDecoder.make())
            .value
    }
}
