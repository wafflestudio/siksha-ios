//
//  RestaurantLocalDataSourceTests.swift
//  SikshaTests
//
//  Created by Codex on 7/14/26.
//

import Foundation
import XCTest
@testable import Siksha

final class RestaurantLocalDataSourceTests: XCTestCase {
    private var suiteName: String!
    private var userDefaults: UserDefaults!

    override func setUp() {
        super.setUp()
        suiteName = "RestaurantLocalDataSourceTests.\(UUID().uuidString)"
        userDefaults = UserDefaults(suiteName: suiteName)
        userDefaults.removePersistentDomain(forName: suiteName)
    }

    override func tearDown() {
        userDefaults.removePersistentDomain(forName: suiteName)
        userDefaults = nil
        suiteName = nil
        super.tearDown()
    }

    func testClearPersonalRestaurantsRemovesOnlyPersonalRestaurantState() {
        let dataSource = RestaurantLocalDataSourceImpl(userDefaults: userDefaults)
        let unrelatedKey = "unrelated-preference"
        userDefaults.set(true, forKey: unrelatedKey)
        dataSource.savePersonalRestaurants([makeRestaurant(id: 1)])

        XCTAssertEqual(dataSource.fetchPersonalRestaurants()?.map(\.id), [1])

        dataSource.clearPersonalRestaurants()

        XCTAssertNil(dataSource.fetchPersonalRestaurants())
        XCTAssertTrue(userDefaults.bool(forKey: unrelatedKey))
    }

    private func makeRestaurant(id: Int) -> PersonalRestaurantDTO {
        PersonalRestaurantDTO(
            createdAt: Date(timeIntervalSince1970: 1),
            updatedAt: Date(timeIntervalSince1970: 2),
            id: id,
            code: "restaurant-\(id)",
            nameKr: "Restaurant KR \(id)",
            nameEn: "Restaurant \(id)",
            addr: nil,
            lat: nil,
            lng: nil,
            liked: true,
            visible: true,
            etc: nil
        )
    }
}
