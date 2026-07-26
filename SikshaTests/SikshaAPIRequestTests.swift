//
//  SikshaAPIRequestTests.swift
//  SikshaTests
//
//  Created by Codex on 7/19/26.
//

import XCTest

@testable import Siksha

final class SikshaAPIRequestTests: XCTestCase {
    func testGetParametersPreserveQueryEncoding() throws {
        let request = try SikshaAPI.getMenus(
            startDate: "2026-07-01",
            endDate: "2026-07-02",
            noMenuHide: false
        ).asURLRequest()

        XCTAssertEqual(request.httpMethod, "GET")
        XCTAssertEqual(request.url?.path, "/menus")
        XCTAssertEqual(
            request.url?.query,
            "end_date=2026-07-02&except_empty=0&start_date=2026-07-01"
        )
    }

    func testJSONParametersPreserveArrayValues() throws {
        let request = try SikshaAPI.setRestaurantOrder(order: [3, 1, 2]).asURLRequest()
        let body = try XCTUnwrap(request.httpBody)
        let parameters = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [String: Any]
        )

        XCTAssertEqual(request.httpMethod, "PATCH")
        XCTAssertEqual(request.url?.path, "/restaurants/order")
        XCTAssertEqual(parameters["order"] as? [Int], [3, 1, 2])
    }

    func testDeleteParametersRemainInJSONBody() throws {
        let request = try SikshaAPI.deleteUserDevice(fcmToken: "device-token").asURLRequest()
        let body = try XCTUnwrap(request.httpBody)
        let parameters = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [String: Any]
        )

        XCTAssertEqual(request.httpMethod, "DELETE")
        XCTAssertEqual(request.url?.path, "/auth/userDevice")
        XCTAssertEqual(parameters["fcm_token"] as? String, "device-token")
    }

    func testEditReviewOmitsNilComment() throws {
        let request = try SikshaAPI.editReview(
            reviewId: 1,
            menuId: 2,
            score: 3,
            comment: nil,
            taste: "good",
            price: "fair",
            foodComposition: "balanced",
            images: nil
        ).asURLRequest()
        let body = try XCTUnwrap(request.httpBody)
        let parameters = try XCTUnwrap(
            JSONSerialization.jsonObject(with: body) as? [String: Any]
        )

        XCTAssertNil(parameters["comment"])
        XCTAssertEqual(parameters["menu_id"] as? Int, 2)
    }

    func testParametersAreSendable() {
        let parameters = SikshaAPI.getReviews(menuId: 1, page: 2, perPage: 3).parameters

        requireSendable(parameters)
    }
}

private func requireSendable<T: Sendable>(_: T) {}
