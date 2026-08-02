//
//  AppVersionPolicyTests.swift
//  SikshaTests
//

import XCTest

@testable import Siksha

final class AppVersionPolicyTests: XCTestCase {
    func testAppVersionRequiresMajorMinorPatch() {
        XCTAssertNotNil(AppVersion(rawValue: "3.5.0"))
        XCTAssertNil(AppVersion(rawValue: "3.5"))
        XCTAssertNil(AppVersion(rawValue: "3.5.0.1"))
        XCTAssertNil(AppVersion(rawValue: "3.-1.0"))
        XCTAssertNil(AppVersion(rawValue: "+3.5.0"))
        XCTAssertNil(AppVersion(rawValue: "3.5.beta"))
    }

    func testAppVersionUsesNumericComparison() throws {
        let lower = try XCTUnwrap(AppVersion(rawValue: "3.9.9"))
        let higher = try XCTUnwrap(AppVersion(rawValue: "3.10.0"))
        let equivalent = try XCTUnwrap(AppVersion(rawValue: "03.10.00"))

        XCTAssertLessThan(lower, higher)
        XCTAssertEqual(higher, equivalent)
    }

    func testUpdateIsRequiredOnlyBelowMinimumVersion() async throws {
        let minimumVersion = try XCTUnwrap(AppVersion(rawValue: "3.5.0"))
        let useCase = DefaultCheckAppUpdateRequirementUseCase(
            repository: VersionPolicyRepositoryStub(result: .success(minimumVersion))
        )

        let below = await useCase.execute(currentVersion: "3.4.9")
        let equal = await useCase.execute(currentVersion: "3.5.0")
        let above = await useCase.execute(currentVersion: "4.0.0")

        XCTAssertEqual(below, .updateRequired)
        XCTAssertEqual(equal, .updateNotRequired)
        XCTAssertEqual(above, .updateNotRequired)
    }

    func testInvalidCurrentVersionIsUnavailable() async throws {
        let minimumVersion = try XCTUnwrap(AppVersion(rawValue: "3.5.0"))
        let useCase = DefaultCheckAppUpdateRequirementUseCase(
            repository: VersionPolicyRepositoryStub(result: .success(minimumVersion))
        )

        let result = await useCase.execute(currentVersion: "invalid")

        XCTAssertEqual(result, .unavailable)
    }

    func testRepositoryFailureIsUnavailable() async {
        let useCase = DefaultCheckAppUpdateRequirementUseCase(
            repository: VersionPolicyRepositoryStub(result: .failure(TestError.expected))
        )

        let result = await useCase.execute(currentVersion: "3.5.0")

        XCTAssertEqual(result, .unavailable)
    }

    func testRepositoryRejectsInvalidServerVersion() async {
        let repository = VersionPolicyRepositoryImpl(
            remote: VersionPolicyRemoteDataSourceStub(minimumVersion: "invalid")
        )

        do {
            _ = try await repository.fetchMinimumSupportedVersion()
            XCTFail("Expected invalid server version to throw")
        } catch {}
    }
}

private final class VersionPolicyRepositoryStub: VersionPolicyRepositoryProtocol {
    private let result: Result<AppVersion, Error>

    init(result: Result<AppVersion, Error>) {
        self.result = result
    }

    func fetchMinimumSupportedVersion() async throws -> AppVersion {
        try result.get()
    }
}

private enum TestError: Error {
    case expected
}

private struct VersionPolicyRemoteDataSourceStub: VersionPolicyRemoteDataSource {
    let minimumVersion: String

    func fetchMinimumSupportedVersion() async throws -> VersionPolicyDTO {
        VersionPolicyDTO(minimumVersion: minimumVersion)
    }
}
