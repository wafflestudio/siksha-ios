//
//  AccountManageViewModelTests.swift
//  SikshaTests
//
//  Created by Codex on 7/13/26.
//

import Foundation
import XCTest
@testable import Siksha

@MainActor
final class AccountManageViewModelTests: XCTestCase {
    func testLogoutSuccessReturnsTrueAndClearsProcessingState() async {
        let logout = LogoutUseCaseStub()
        let viewModel = makeViewModel(logout: logout)

        let result = await viewModel.logout()

        XCTAssertTrue(result)
        XCTAssertEqual(logout.executionCount, 1)
        XCTAssertFalse(viewModel.isProcessing)
        XCTAssertFalse(viewModel.logoutFailed)
    }

    func testLogoutFailureUpdatesFailureState() async {
        let viewModel = makeViewModel(
            logout: LogoutUseCaseStub(result: .failure(AccountViewModelTestError.expected))
        )

        let result = await viewModel.logout()

        XCTAssertFalse(result)
        XCTAssertTrue(viewModel.logoutFailed)
        XCTAssertNotNil(viewModel.error)
        XCTAssertFalse(viewModel.isProcessing)
    }

    func testDeleteAccountSuccessReturnsTrue() async {
        let deleteAccount = DeleteAccountUseCaseStub()
        let viewModel = makeViewModel(deleteAccount: deleteAccount)

        let result = await viewModel.deleteAccount()

        XCTAssertTrue(result)
        XCTAssertEqual(deleteAccount.executionCount, 1)
        XCTAssertFalse(viewModel.deleteAccountFailed)
    }

    func testDeleteAccountFailureUpdatesFailureState() async {
        let viewModel = makeViewModel(
            deleteAccount: DeleteAccountUseCaseStub(
                result: .failure(AccountViewModelTestError.expected)
            )
        )

        let result = await viewModel.deleteAccount()

        XCTAssertFalse(result)
        XCTAssertTrue(viewModel.deleteAccountFailed)
        XCTAssertNotNil(viewModel.error)
    }

    func testDeleteAccountFailureUsesOriginalDeletionErrorForPresentation() async {
        let deletionError = URLError(.notConnectedToInternet)
        let failure = DeleteAccountFailure(
            accountDeletionError: deletionError,
            deviceRestorationError: AccountViewModelTestError.expected
        )
        let viewModel = makeViewModel(
            deleteAccount: DeleteAccountUseCaseStub(result: .failure(failure))
        )

        let result = await viewModel.deleteAccount()

        XCTAssertFalse(result)
        XCTAssertEqual(
            viewModel.error?.errorDescription,
            ErrorHelper.categorize(deletionError).errorDescription
        )
    }

    func testConcurrentActionIsRejected() async {
        let logout = LogoutUseCaseStub(delayNanoseconds: 100_000_000)
        let deleteAccount = DeleteAccountUseCaseStub()
        let viewModel = makeViewModel(logout: logout, deleteAccount: deleteAccount)

        let logoutTask = Task { await viewModel.logout() }
        await Task.yield()

        let deleteResult = await viewModel.deleteAccount()
        let logoutResult = await logoutTask.value

        XCTAssertFalse(deleteResult)
        XCTAssertTrue(logoutResult)
        XCTAssertEqual(logout.executionCount, 1)
        XCTAssertEqual(deleteAccount.executionCount, 0)
    }

    private func makeViewModel(
        logout: LogoutUseCaseStub = LogoutUseCaseStub(),
        deleteAccount: DeleteAccountUseCaseStub = DeleteAccountUseCaseStub()
    ) -> AccountManageViewModel {
        AccountManageViewModel(
            logoutUseCase: logout,
            deleteAccountUseCase: deleteAccount
        )
    }
}

private enum AccountViewModelTestError: Error {
    case expected
}

private final class LogoutUseCaseStub: LogoutUseCase {
    private let result: Result<Void, Error>
    private let delayNanoseconds: UInt64
    private(set) var executionCount = 0

    init(
        result: Result<Void, Error> = .success(()),
        delayNanoseconds: UInt64 = 0
    ) {
        self.result = result
        self.delayNanoseconds = delayNanoseconds
    }

    func execute() async throws {
        executionCount += 1
        if delayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
        try result.get()
    }
}

private final class DeleteAccountUseCaseStub: DeleteAccountUseCase {
    private let result: Result<Void, Error>
    private(set) var executionCount = 0

    init(result: Result<Void, Error> = .success(())) {
        self.result = result
    }

    func execute() async throws {
        executionCount += 1
        try result.get()
    }
}
