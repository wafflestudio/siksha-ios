//
//  AuthSessionLocalDataSourceTests.swift
//  SikshaTests
//
//  Created by Codex on 7/16/26.
//

import Foundation
import XCTest
@testable import Siksha

final class AuthSessionLocalDataSourceTests: XCTestCase {
    private enum Key {
        static let accessToken = "accessToken"
        static let tokenExpDate = "tokenExpDate"
        static let appleUserIdentifier = "appleUserIdentifier"
        static let signedInWithApple = "signedInWithApple"
    }

    private var suiteName: String!
    private var userDefaults: UserDefaults!
    private var dataSource: AuthSessionLocalDataSourceImpl!

    override func setUp() {
        super.setUp()
        suiteName = "AuthSessionLocalDataSourceTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
        dataSource = AuthSessionLocalDataSourceImpl(userDefaults: userDefaults)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        dataSource = nil
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testLoadSessionWithoutAccessTokenReturnsNil() {
        userDefaults.set(123, forKey: Key.tokenExpDate)
        userDefaults.set("apple-user", forKey: Key.appleUserIdentifier)
        userDefaults.set(true, forKey: Key.signedInWithApple)

        XCTAssertNil(dataSource.loadSession())
    }

    func testLoadSessionRestoresExistingStorageKeys() throws {
        let expiration = Date(timeIntervalSince1970: 2_000_000_000)
        userDefaults.set("access-token", forKey: Key.accessToken)
        userDefaults.set(expiration.timeIntervalSince1970, forKey: Key.tokenExpDate)
        userDefaults.set("apple-user", forKey: Key.appleUserIdentifier)
        userDefaults.set(true, forKey: Key.signedInWithApple)

        let session = try XCTUnwrap(dataSource.loadSession())

        XCTAssertEqual(session.accessToken, "access-token")
        XCTAssertEqual(session.expiresAt, expiration)
        XCTAssertEqual(session.appleUserIdentifier, "apple-user")
    }

    func testLoadSessionIgnoresStaleAppleIdentifierWhenFlagIsFalse() throws {
        userDefaults.set("access-token", forKey: Key.accessToken)
        userDefaults.set("stale-apple-user", forKey: Key.appleUserIdentifier)
        userDefaults.set(false, forKey: Key.signedInWithApple)

        let session = try XCTUnwrap(dataSource.loadSession())

        XCTAssertNil(session.appleUserIdentifier)
    }

    func testSaveAppleSessionWritesExistingStorageKeys() {
        let expiration = Date(timeIntervalSince1970: 2_000_000_000)

        dataSource.saveSession(
            AuthSession(
                accessToken: "access-token",
                expiresAt: expiration,
                appleUserIdentifier: "apple-user"
            )
        )

        XCTAssertEqual(userDefaults.string(forKey: Key.accessToken), "access-token")
        XCTAssertEqual(
            userDefaults.double(forKey: Key.tokenExpDate),
            expiration.timeIntervalSince1970
        )
        XCTAssertEqual(
            userDefaults.string(forKey: Key.appleUserIdentifier),
            "apple-user"
        )
        XCTAssertTrue(userDefaults.bool(forKey: Key.signedInWithApple))
    }

    func testSaveNonAppleSessionClearsStaleExpirationAndAppleState() {
        userDefaults.set(1_900_000_000, forKey: Key.tokenExpDate)
        userDefaults.set("stale-apple-user", forKey: Key.appleUserIdentifier)
        userDefaults.set(true, forKey: Key.signedInWithApple)

        dataSource.saveSession(
            AuthSession(
                accessToken: "new-access-token",
                expiresAt: nil
            )
        )

        XCTAssertEqual(userDefaults.string(forKey: Key.accessToken), "new-access-token")
        XCTAssertNil(userDefaults.object(forKey: Key.tokenExpDate))
        XCTAssertNil(userDefaults.object(forKey: Key.appleUserIdentifier))
        XCTAssertFalse(userDefaults.bool(forKey: Key.signedInWithApple))
    }

    func testClearSessionRemovesOnlyAuthKeys() {
        userDefaults.set("access-token", forKey: Key.accessToken)
        userDefaults.set(2_000_000_000, forKey: Key.tokenExpDate)
        userDefaults.set("apple-user", forKey: Key.appleUserIdentifier)
        userDefaults.set(true, forKey: Key.signedInWithApple)
        userDefaults.set("keep-me", forKey: "unrelatedKey")

        dataSource.clearSession()

        XCTAssertNil(userDefaults.object(forKey: Key.accessToken))
        XCTAssertNil(userDefaults.object(forKey: Key.tokenExpDate))
        XCTAssertNil(userDefaults.object(forKey: Key.appleUserIdentifier))
        XCTAssertNil(userDefaults.object(forKey: Key.signedInWithApple))
        XCTAssertEqual(userDefaults.string(forKey: "unrelatedKey"), "keep-me")
    }
}
