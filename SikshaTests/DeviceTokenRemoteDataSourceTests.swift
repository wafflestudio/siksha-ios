//
//  DeviceTokenRemoteDataSourceTests.swift
//  SikshaTests
//
//  Created by Codex on 7/13/26.
//

import Alamofire
import XCTest

@testable import Siksha

final class DeviceTokenRemoteDataSourceTests: XCTestCase {
    func testRegisterAcceptsEmptySuccessResponses() async throws {
        for statusCode in [200, 201, 204] {
            let dataSource = makeDataSource(statusCode: statusCode)

            try await dataSource.register(fcmToken: "token")
        }
    }

    func testUnregisterTreatsNotFoundAsIdempotentSuccess() async throws {
        for statusCode in [200, 204, 404] {
            let dataSource = makeDataSource(statusCode: statusCode)

            try await dataSource.unregister(fcmToken: "token")
        }
    }

    func testServerFailureIsPropagated() async {
        let dataSource = makeDataSource(statusCode: 500)

        do {
            try await dataSource.unregister(fcmToken: "token")
            XCTFail("Expected HTTP validation failure")
        } catch {
            XCTAssertNotNil(error as? AFError)
        }
    }

    private func makeDataSource(statusCode: Int) -> DeviceTokenRemoteDataSourceImpl {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        configuration.httpAdditionalHeaders = [URLProtocolStub.statusCodeHeader: String(statusCode)]
        return DeviceTokenRemoteDataSourceImpl(
            session: Session(configuration: configuration)
        )
    }
}

private final class URLProtocolStub: URLProtocol {
    static let statusCodeHeader = "X-Test-Status-Code"

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let statusCode = Int(request.value(forHTTPHeaderField: Self.statusCodeHeader) ?? "") ?? 200
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data())
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
