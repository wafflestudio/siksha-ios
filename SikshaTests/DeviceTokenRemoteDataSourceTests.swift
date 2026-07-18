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
    override func tearDown() {
        URLProtocolStub.statusCode = 200
        super.tearDown()
    }

    func testRegisterAcceptsEmptySuccessResponses() async throws {
        for statusCode in [200, 201, 204] {
            URLProtocolStub.statusCode = statusCode
            let dataSource = makeDataSource()

            try await dataSource.register(fcmToken: "token")
        }
    }

    func testUnregisterTreatsNotFoundAsIdempotentSuccess() async throws {
        for statusCode in [200, 204, 404] {
            URLProtocolStub.statusCode = statusCode
            let dataSource = makeDataSource()

            try await dataSource.unregister(fcmToken: "token")
        }
    }

    func testServerFailureIsPropagated() async {
        URLProtocolStub.statusCode = 500
        let dataSource = makeDataSource()

        do {
            try await dataSource.unregister(fcmToken: "token")
            XCTFail("Expected HTTP validation failure")
        } catch {
            XCTAssertNotNil(error as? AFError)
        }
    }

    private func makeDataSource() -> DeviceTokenRemoteDataSourceImpl {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [URLProtocolStub.self]
        return DeviceTokenRemoteDataSourceImpl(
            session: Session(configuration: configuration)
        )
    }
}

private final class URLProtocolStub: URLProtocol {
    static var statusCode = 200

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: Self.statusCode,
            httpVersion: nil,
            headerFields: nil
        )!
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocol(self, didLoad: Data())
        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}
}
