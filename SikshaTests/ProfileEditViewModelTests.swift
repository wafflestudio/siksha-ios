//
//  ProfileEditViewModelTests.swift
//  SikshaTests
//

import XCTest
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
        fetch: FetchCurrentUserUseCaseStub = FetchCurrentUserUseCaseStub(user: .fixture()),
        update: UpdateUserProfileUseCaseStub = UpdateUserProfileUseCaseStub(result: .success(.fixture())),
        onUserUpdated: @escaping (User) -> Void = { _ in }
    ) -> ProfileEditViewModel {
        ProfileEditViewModel(
            fetchCurrentUserUseCase: fetch,
            updateUserProfileUseCase: update,
            onUserUpdated: onUserUpdated
        )
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
