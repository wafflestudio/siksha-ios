//
//  SharedStateTests.swift
//  SikshaTests
//

import SwiftUI
import XCTest

@testable import Siksha

@MainActor
final class SharedStateTests: XCTestCase {
    func testEnvironmentDefaultsAreInert() {
        let environment = EnvironmentValues()

        XCTAssertNil(environment.viewController)
        XCTAssertEqual(environment.safeAreaInsets, EdgeInsets())
        XCTAssertNil(environment.imageCache)
    }

    func testBlockedNicknamesPersistWithoutDuplicates() throws {
        let (manager, userDefaults, suiteName) = try makeBlockManager()
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        manager.blockNickname("blocked-user")
        manager.blockNickname("blocked-user")

        let reloadedManager = BlockManager(userDefaults: userDefaults)
        XCTAssertEqual(reloadedManager.blockedNicknames(), ["blocked-user"])
    }

    func testBlockedPostIdsPersist() throws {
        let (manager, userDefaults, suiteName) = try makeBlockManager()
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        manager.blockPost(id: 10)
        manager.blockPost(id: 20)

        let reloadedManager = BlockManager(userDefaults: userDefaults)
        XCTAssertEqual(reloadedManager.blockedPostIds(), [10, 20])
    }

    func testBlockedCommentIdsPersist() throws {
        let (manager, userDefaults, suiteName) = try makeBlockManager()
        defer { userDefaults.removePersistentDomain(forName: suiteName) }

        manager.blockComment(id: 30)
        manager.blockComment(id: 40)

        let reloadedManager = BlockManager(userDefaults: userDefaults)
        XCTAssertEqual(reloadedManager.blockedCommentIds(), [30, 40])
    }

    private func makeBlockManager() throws -> (BlockManager, UserDefaults, String) {
        let suiteName = "SharedStateTests.\(UUID().uuidString)"
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        userDefaults.removePersistentDomain(forName: suiteName)
        return (BlockManager(userDefaults: userDefaults), userDefaults, suiteName)
    }
}
