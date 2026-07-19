//
//  MenuRepositoryTests.swift
//  SikshaTests
//
//  Created by Codex on 7/19/26.
//

import XCTest

@testable import Siksha

@MainActor
final class FetchDailyMenuUseCaseTests: XCTestCase {
    func testSucceededWhenRefreshAndCachedReadSucceed() async {
        let expectedMenu = MenuFixture(date: "2026-07-19", dateType: "WEEKDAY").makeModel()
        let useCase = DefaultFetchDailyMenuUseCase(
            repository: MenuRepositoryStub(
                refreshResult: .success(true),
                cachedMenu: expectedMenu
            )
        )

        let result = await useCase.execute(date: expectedMenu.date)

        guard case .succeeded(let menu) = result else {
            return XCTFail("Expected succeeded result")
        }
        XCTAssertEqual(menu.date, expectedMenu.date)
    }

    func testEmptyWhenRefreshReturnsNoMenu() async {
        let useCase = DefaultFetchDailyMenuUseCase(
            repository: MenuRepositoryStub(refreshResult: .success(false))
        )

        let result = await useCase.execute(date: "2026-07-19")

        guard case .empty = result else {
            return XCTFail("Expected empty result")
        }
    }

    func testCachedWhenRefreshFailsAndCachedMenuExists() async {
        let expectedMenu = MenuFixture(date: "2026-07-19", dateType: "WEEKDAY").makeModel()
        let useCase = DefaultFetchDailyMenuUseCase(
            repository: MenuRepositoryStub(
                refreshResult: .failure(.remoteFailed),
                cachedMenu: expectedMenu
            )
        )

        let result = await useCase.execute(date: expectedMenu.date)

        guard case .cached(let menu) = result else {
            return XCTFail("Expected cached result")
        }
        XCTAssertEqual(menu.date, expectedMenu.date)
    }

    func testFailedWhenRefreshFailsWithoutCachedMenu() async {
        let useCase = DefaultFetchDailyMenuUseCase(
            repository: MenuRepositoryStub(refreshResult: .failure(.remoteFailed))
        )

        let result = await useCase.execute(date: "2026-07-19")

        guard case .failed = result else {
            return XCTFail("Expected failed result")
        }
    }
}

@MainActor
final class MenuRepositoryImplTests: XCTestCase {
    func testBoundaryImplementationsAreSendable() {
        requireSendable(MenuRepositoryImpl.self)
        requireSendable(MenuRemoteDataSourceImpl.self)
        requireSendable(MenuLocalDataSourceImpl.self)
    }

    func testRefreshSavesMappedMenusAndReturnsTrue() async throws {
        let fixture = MenuFixture(date: "2026-07-19", dateType: "SATURDAY")
        let repository = makeRepository(
            remoteResult: .success(makeResponse(fixtures: [fixture])),
            expectedRange: fixture.date...fixture.date,
            expectedSavedDates: [fixture.date]
        )

        let didRefresh = try await repository.refreshMenu(date: fixture.date)

        XCTAssertTrue(didRefresh)
    }

    func testRefreshReturnsFalseWithoutSavingWhenResponseIsEmpty() async throws {
        let date = "2026-07-19"
        let repository = makeRepository(
            remoteResult: .success(makeResponse(fixtures: [])),
            expectedRange: date...date,
            expectedSavedDates: nil
        )

        let didRefresh = try await repository.refreshMenu(date: date)

        XCTAssertFalse(didRefresh)
    }

    func testGetMenusSavesRemoteMenusAndMapsLocalResults() async throws {
        let remoteFixture = MenuFixture(date: "2026-07-19", dateType: "WEEKDAY")
        let localFixture = MenuFixture(date: "2026-07-20", dateType: "HOLIDAY")
        let repository = makeRepository(
            remoteResult: .success(makeResponse(fixtures: [remoteFixture])),
            expectedRange: remoteFixture.date...localFixture.date,
            expectedSavedDates: [remoteFixture.date],
            fetchedFixtures: [localFixture]
        )

        let menus = try await repository.getMenus(
            from: remoteFixture.date,
            to: localFixture.date
        )

        XCTAssertEqual(menus.map(\.date), [localFixture.date])
        guard let menu = menus.first else {
            return XCTFail("Expected mapped menu")
        }
        guard case .holiday = menu.dateType else {
            return XCTFail("Expected holiday date type")
        }
    }

    func testRefreshPropagatesRemoteFailureWithoutSaving() async {
        let date = "2026-07-19"
        let repository = makeRepository(
            remoteResult: .failure(.remoteFailed),
            expectedRange: date...date,
            expectedSavedDates: nil
        )

        do {
            _ = try await repository.refreshMenu(date: date)
            XCTFail("Expected remote error")
        } catch let error as MenuRepositoryTestError {
            XCTAssertEqual(error, .remoteFailed)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    private func makeRepository(
        remoteResult: Result<DailyMenusResponseDTO, MenuRepositoryTestError>,
        expectedRange: ClosedRange<String>,
        expectedSavedDates: [String]?,
        fetchedFixtures: [MenuFixture] = []
    ) -> MenuRepositoryImpl {
        MenuRepositoryImpl(
            remote: MenuRemoteDataSourceStub(
                expectedRange: expectedRange,
                result: remoteResult
            ),
            local: MenuLocalDataSourceStub(
                expectedSavedDates: expectedSavedDates,
                fetchedFixtures: fetchedFixtures
            )
        )
    }

    private func makeResponse(fixtures: [MenuFixture]) -> DailyMenusResponseDTO {
        DailyMenusResponseDTO(
            count: fixtures.count,
            result: fixtures.map { $0.makeDTO() }
        )
    }
}

private enum MenuRepositoryTestError: Error, Equatable, Sendable {
    case remoteFailed
    case unexpectedRange
    case unexpectedSave
}

private struct MenuFixture: Sendable {
    let date: String
    let dateType: String

    func makeDTO() -> DailyMenusDTO {
        DailyMenusDTO(
            date: date,
            dateType: dateType,
            br: [],
            lu: [],
            dn: []
        )
    }

    func makeRealmObject() -> DailyMenu {
        makeDTO().toRealmObject()
    }

    func makeModel() -> DailyMenuModel {
        makeRealmObject().toModel()
    }
}

private struct MenuRepositoryStub: MenuRepositoryProtocol {
    let refreshResult: Result<Bool, MenuRepositoryTestError>
    let cachedMenu: DailyMenuModel?

    init(
        refreshResult: Result<Bool, MenuRepositoryTestError>,
        cachedMenu: DailyMenuModel? = nil
    ) {
        self.refreshResult = refreshResult
        self.cachedMenu = cachedMenu
    }

    @concurrent
    func refreshMenu(date: String) async throws -> Bool {
        try refreshResult.get()
    }

    @concurrent
    func getMenus(from start: String, to end: String) async throws -> [DailyMenuModel] {
        []
    }

    func getMenu(date: String) -> DailyMenuModel? {
        cachedMenu
    }
}

private struct MenuRemoteDataSourceStub: MenuRemoteDataSource {
    let expectedRange: ClosedRange<String>
    let result: Result<DailyMenusResponseDTO, MenuRepositoryTestError>

    func fetchDailyMenus(from start: String, to end: String) async throws -> DailyMenusResponseDTO {
        guard start == expectedRange.lowerBound, end == expectedRange.upperBound else {
            throw MenuRepositoryTestError.unexpectedRange
        }
        return try result.get()
    }
}

private struct MenuLocalDataSourceStub: MenuLocalDataSource {
    let expectedSavedDates: [String]?
    let fetchedFixtures: [MenuFixture]

    func saveDailyMenus(_ menus: [DailyMenu]) throws {
        guard let expectedSavedDates else {
            throw MenuRepositoryTestError.unexpectedSave
        }
        guard menus.map(\.date) == expectedSavedDates else {
            throw MenuRepositoryTestError.unexpectedSave
        }
    }

    func fetchDailyMenus(from start: String, to end: String) throws -> [DailyMenu] {
        fetchedFixtures.map { $0.makeRealmObject() }
    }

    func fetchDailyMenu(date: String) throws -> DailyMenu? {
        fetchedFixtures.first(where: { $0.date == date })?.makeRealmObject()
    }

    func deleteAll() throws {}
}

private func requireSendable<T: Sendable>(_ type: T.Type) {}
