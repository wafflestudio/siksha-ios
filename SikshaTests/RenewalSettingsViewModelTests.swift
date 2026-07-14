//
//  RenewalSettingsViewModelTests.swift
//  SikshaTests
//

import XCTest
@testable import Siksha

@MainActor
final class RenewalSettingsViewModelTests: XCTestCase {
    func testLoadIfNeededFetchesUserAndVersionOnlyOnce() async {
        let fetchUser = SettingsFetchCurrentUserUseCaseStub(user: .settingsFixture())
        let fetchVersion = FetchAppStoreVersionUseCaseStub(version: AppVersion(rawValue: "2.0.0"))
        let viewModel = makeViewModel(fetchUser: fetchUser, fetchVersion: fetchVersion)

        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        XCTAssertEqual(viewModel.user?.nickname, "설정 닉네임")
        XCTAssertEqual(viewModel.userId, 10)
        XCTAssertEqual(viewModel.appStoreVersion, "2.0.0")
        XCTAssertEqual(fetchUser.executionCount, 1)
        XCTAssertEqual(fetchVersion.executionCount, 1)
    }

    func testApplyUpdatedUserRefreshesSettingsState() {
        let viewModel = makeViewModel()

        viewModel.applyUpdatedUser(.settingsFixture(id: 20, nickname: "수정 닉네임"))

        XCTAssertEqual(viewModel.user?.nickname, "수정 닉네임")
        XCTAssertEqual(viewModel.userId, 20)
    }

    func testLoadIfNeededRetriesOnlyFailedRequest() async {
        let fetchUser = SettingsFetchCurrentUserUseCaseStub(user: .settingsFixture())
        let fetchVersion = FetchAppStoreVersionUseCaseStub(
            results: [.failure(TestError.expected), .success(AppVersion(rawValue: "2.0.0"))]
        )
        let viewModel = makeViewModel(fetchUser: fetchUser, fetchVersion: fetchVersion)

        await viewModel.loadIfNeeded()
        await viewModel.loadIfNeeded()

        XCTAssertEqual(fetchUser.executionCount, 1)
        XCTAssertEqual(fetchVersion.executionCount, 2)
        XCTAssertEqual(viewModel.appStoreVersion, "2.0.0")
    }

    func testSendVOCTransitionsToSucceeded() async {
        let submitVOC = SubmitVOCUseCaseStub(result: .success(()))
        let viewModel = makeViewModel(submitVOC: submitVOC)
        viewModel.vocComment = "문의 내용"

        await viewModel.sendVOC()

        guard case .succeeded = viewModel.postVOCStatus else {
            return XCTFail("Expected succeeded status")
        }
        XCTAssertEqual(submitVOC.comment, "문의 내용")
        XCTAssertEqual(submitVOC.platform, "iOS")
        XCTAssertEqual(viewModel.alertMessage, "전송했습니다.")
        XCTAssertTrue(viewModel.showAlert)
    }

    private func makeViewModel(
        fetchUser: SettingsFetchCurrentUserUseCaseStub = SettingsFetchCurrentUserUseCaseStub(user: .settingsFixture()),
        submitVOC: SubmitVOCUseCaseStub = SubmitVOCUseCaseStub(result: .success(())),
        fetchVersion: FetchAppStoreVersionUseCaseStub = FetchAppStoreVersionUseCaseStub(version: AppVersion(rawValue: "1.0.0"))
    ) -> RenewalSettingsViewModel {
        RenewalSettingsViewModel(
            manageRestaurantsWithoutMenuVisibilityUseCase: ManageRestaurantsWithoutMenuVisibilityUseCaseStub(),
            fetchCurrentUserUseCase: fetchUser,
            submitVOCUseCase: submitVOC,
            fetchAppStoreVersionUseCase: fetchVersion,
            version: "1.0.0"
        )
    }
}

private final class SettingsFetchCurrentUserUseCaseStub: FetchCurrentUserUseCase {
    let user: User
    private(set) var executionCount = 0

    init(user: User) {
        self.user = user
    }

    func execute() async throws -> User {
        executionCount += 1
        return user
    }
}

private final class SubmitVOCUseCaseStub: SubmitVOCUseCase {
    let result: Result<Void, Error>
    private(set) var comment: String?
    private(set) var platform: String?

    init(result: Result<Void, Error>) {
        self.result = result
    }

    func execute(comment: String, platform: String) async throws {
        self.comment = comment
        self.platform = platform
        try result.get()
    }
}

private final class FetchAppStoreVersionUseCaseStub: FetchAppStoreVersionUseCase {
    private var results: [Result<AppVersion, Error>]
    private(set) var executionCount = 0

    init(version: AppVersion) {
        self.results = [.success(version)]
    }

    init(results: [Result<AppVersion, Error>]) {
        self.results = results
    }

    func execute() async throws -> AppVersion {
        executionCount += 1
        return try results.removeFirst().get()
    }
}

private enum TestError: Error {
    case expected
}

private final class ManageRestaurantsWithoutMenuVisibilityUseCaseStub: ManageRestaurantsWithoutMenuVisibilityUseCase {
    func shouldHideRestaurantsWithoutMenu() -> Bool { false }
    func setShouldHideRestaurantsWithoutMenu(_ shouldHide: Bool) {}
}

private extension User {
    static func settingsFixture(id: Int = 10, nickname: String? = "설정 닉네임") -> User {
        User(
            id: id,
            type: "apple",
            identity: "identity",
            nickname: nickname,
            profileUrl: "https://example.com/profile.jpg",
            createdAt: Date(timeIntervalSince1970: 0),
            updatedAt: Date(timeIntervalSince1970: 0)
        )
    }
}
