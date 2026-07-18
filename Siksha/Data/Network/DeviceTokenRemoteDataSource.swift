//
//  DeviceTokenRemoteDataSource.swift
//  Siksha
//
//  Created by Codex on 7/13/26.
//

import Alamofire

protocol DeviceTokenRemoteDataSource {
    func register(fcmToken: String) async throws
    func unregister(fcmToken: String) async throws
}

final class DeviceTokenRemoteDataSourceImpl: DeviceTokenRemoteDataSource {
    private let session: Session

    init(session: Session = .default) {
        self.session = session
    }

    func register(fcmToken: String) async throws {
        try await performRequest(
            SikshaAPI.postUserDevice(fcmToken: fcmToken),
            acceptedStatusCodes: [200, 201, 204]
        )
    }

    func unregister(fcmToken: String) async throws {
        try await performRequest(
            SikshaAPI.deleteUserDevice(fcmToken: fcmToken),
            acceptedStatusCodes: [200, 201, 204, 404]
        )
    }

    private func performRequest(
        _ endpoint: SikshaAPI,
        acceptedStatusCodes: [Int]
    ) async throws {
        _ =
            try await session
            .request(endpoint)
            .validate(statusCode: acceptedStatusCodes)
            .serializingData(emptyResponseCodes: Set(acceptedStatusCodes))
            .value
    }
}
