//
//  ProfileEditViewModelTests.swift
//  SikshaTests
//

import XCTest
import UIKit
@testable import Siksha

@MainActor
final class ProfileEditViewModelTests: XCTestCase {
    func testLoadPopulatesEditableUserStateOnlyOnce() async {
        let fetch = FetchCurrentUserUseCaseStub(user: .fixture())
        let viewModel = makeViewModel(fetch: fetch)

        await viewModel.loadInfo()
        await viewModel.loadInfo()

        XCTAssertEqual(viewModel.nickname, "기존 닉네임")
        XCTAssertEqual(viewModel.profileImageURL, "https://example.com/profile.jpg")
        XCTAssertNil(viewModel.profileImageData)
        XCTAssertFalse(viewModel.enableDoneButton)
        XCTAssertEqual(fetch.executionCount, 1)
    }

    func testImageSelectedWhileInitialLoadIsPendingIsNotOverwritten() async {
        let fetchStarted = expectation(description: "fetch started")
        let fetch = DelayedFetchCurrentUserUseCaseStub(
            user: .fixture(),
            onStart: { fetchStarted.fulfill() }
        )
        let viewModel = makeViewModel(fetch: fetch)
        let selectedImage = Data([0x01, 0x02, 0x03])

        let loadTask = Task { await viewModel.loadInfo() }
        await fulfillment(of: [fetchStarted], timeout: 1)
        XCTAssertTrue(viewModel.isLoading)
        XCTAssertFalse(viewModel.enableDoneButton)

        viewModel.setProfileImage(with: selectedImage)
        fetch.complete()
        await loadTask.value

        XCTAssertEqual(viewModel.profileImageData, selectedImage)
        XCTAssertNil(viewModel.profileImageURL)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertTrue(viewModel.enableDoneButton)
    }

    func testResizeLimitsLongestPixelDimensionAndPreservesAspectRatio() throws {
        let source = UIGraphicsImageRenderer(size: CGSize(width: 4_000, height: 1_000)).image { context in
            UIColor.orange.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 4_000, height: 1_000))
        }

        let resized = try XCTUnwrap(source.resizedToFit(maxPixelDimension: 800))

        XCTAssertEqual(resized.scale, 1)
        XCTAssertEqual(resized.size.width, 800)
        XCTAssertEqual(resized.size.height, 200)
    }

    func testResizeDoesNotUpscaleSmallImage() throws {
        let source = UIGraphicsImageRenderer(size: CGSize(width: 200, height: 100)).image { _ in }

        let resized = try XCTUnwrap(source.resizedToFit(maxPixelDimension: 800))

        XCTAssertTrue(resized === source)
    }

    func testUpdatePassesOnlyChangedNicknameAndCallsBackWithUpdatedUser() async {
        let updatedUser = User.fixture(nickname: "새 닉네임")
        let update = UpdateUserProfileUseCaseStub(result: .success(updatedUser))
        var callbackUser: User?
        let viewModel = makeViewModel(
            update: update,
            onUserUpdated: { callbackUser = $0 }
        )
        await viewModel.loadInfo()
        viewModel.nickname = "새 닉네임"

        await viewModel.updateUserProfile()

        XCTAssertEqual(update.nickname, "새 닉네임")
        XCTAssertNil(update.image)
        XCTAssertFalse(update.changeToDefaultImage)
        XCTAssertEqual(callbackUser?.nickname, "새 닉네임")
        XCTAssertTrue(viewModel.shouldDismiss)
    }

    func testSelectingDefaultImageRequestsDefaultWithoutImageData() async {
        let update = UpdateUserProfileUseCaseStub(result: .success(.fixture(profileUrl: nil)))
        let viewModel = makeViewModel(update: update)
        await viewModel.loadInfo()

        viewModel.setProfileImage(with: nil)
        await viewModel.updateUserProfile()

        XCTAssertNil(update.nickname)
        XCTAssertNil(update.image)
        XCTAssertTrue(update.changeToDefaultImage)
    }

    func testSelectingNewImagePassesImageWithoutDefaultFlag() async {
        let image = Data([0x01, 0x02])
        let update = UpdateUserProfileUseCaseStub(result: .success(.fixture()))
        let viewModel = makeViewModel(update: update)
        await viewModel.loadInfo()

        viewModel.setProfileImage(with: image)
        await viewModel.updateUserProfile()

        XCTAssertEqual(update.image, image)
        XCTAssertFalse(update.changeToDefaultImage)
    }

    func testConflictShowsNicknameToastWithoutDismissing() async {
        let update = UpdateUserProfileUseCaseStub(result: .failure(NetworkError.conflict))
        let viewModel = makeViewModel(update: update)
        await viewModel.loadInfo()
        viewModel.nickname = "중복 닉네임"

        await viewModel.updateUserProfile()

        XCTAssertTrue(viewModel.showNicknameExistsToast)
        XCTAssertFalse(viewModel.shouldDismiss)
    }

    private func makeViewModel(
        fetch: FetchCurrentUserUseCase = FetchCurrentUserUseCaseStub(user: .fixture()),
        update: UpdateUserProfileUseCase = UpdateUserProfileUseCaseStub(result: .success(.fixture())),
        onUserUpdated: @escaping (User) -> Void = { _ in }
    ) -> ProfileEditViewModel {
        ProfileEditViewModel(
            fetchCurrentUserUseCase: fetch,
            updateUserProfileUseCase: update,
            onUserUpdated: onUserUpdated
        )
    }
}

private final class DelayedFetchCurrentUserUseCaseStub: FetchCurrentUserUseCase {
    let user: User
    let onStart: () -> Void
    private var continuation: CheckedContinuation<User, Never>?

    init(user: User, onStart: @escaping () -> Void) {
        self.user = user
        self.onStart = onStart
    }

    func execute() async throws -> User {
        onStart()
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func complete() {
        continuation?.resume(returning: user)
        continuation = nil
    }
}

private final class FetchCurrentUserUseCaseStub: FetchCurrentUserUseCase {
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

private final class UpdateUserProfileUseCaseStub: UpdateUserProfileUseCase {
    let result: Result<User, Error>
    private(set) var nickname: String?
    private(set) var image: Data?
    private(set) var changeToDefaultImage = false

    init(result: Result<User, Error>) {
        self.result = result
    }

    func execute(
        nickname: String?,
        image: Data?,
        changeToDefaultImage: Bool
    ) async throws -> User {
        self.nickname = nickname
        self.image = image
        self.changeToDefaultImage = changeToDefaultImage
        return try result.get()
    }
}

private extension User {
    static func fixture(
        nickname: String? = "기존 닉네임",
        profileUrl: String? = "https://example.com/profile.jpg"
    ) -> User {
        User(
            id: 1,
            type: "apple",
            identity: "identity",
            nickname: nickname,
            profileUrl: profileUrl,
            createdAt: Date(timeIntervalSince1970: 0),
            updatedAt: Date(timeIntervalSince1970: 0)
        )
    }
}
