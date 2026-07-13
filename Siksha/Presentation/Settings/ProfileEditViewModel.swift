//
//  ProfileEditViewModel.swift
//  Siksha
//
//  Created by 이지현 on 5/12/24.
//

import Combine
import Foundation

@MainActor
protocol ProfileEditViewModelType: ObservableObject {
    var error: AppError? { get set }
    var nickname: String { get set }
    var profileImageData: Data? { get set }
    var profileImageURL: String? { get }
    var enableDoneButton: Bool { get }
    var isLoading: Bool { get }
    var showNicknameExistsToast: Bool { get }
    var shouldDismiss: Bool { get }

    func loadInfo() async
    func resetNickname()
    func setPreviousNickname()
    func updateUserProfile() async
    func setProfileImage(with imageData: Data?)
}

@MainActor
final class ProfileEditViewModel: ProfileEditViewModelType {
    @Published var error: AppError?
    @Published var nickname = ""
    @Published var profileImageData: Data?
    @Published private(set) var profileImageURL: String?
    @Published private(set) var enableDoneButton = false
    @Published private(set) var isLoading = true
    @Published private(set) var showNicknameExistsToast = false
    @Published private(set) var shouldDismiss = false
    @Published private var isProfileImageChanged = false

    private let fetchCurrentUserUseCase: FetchCurrentUserUseCase
    private let updateUserProfileUseCase: UpdateUserProfileUseCase
    private let onUserUpdated: (User) -> Void
    private var cancellables = Set<AnyCancellable>()
    private var toastWorkItem: DispatchWorkItem?
    private var originalNickname: String?
    private var previousNickname: String?
    private var shouldUseDefaultProfileImage = false
    @Published private var hasLoaded = false
    private var isLoadInProgress = false

    private var doneButtonEnabledPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest3($nickname, $isProfileImageChanged, $hasLoaded)
            .map { [weak self] nickname, isProfileImageChanged, hasLoaded in
                guard let self else { return false }
                return hasLoaded
                    && !nickname.isEmpty
                    && (nickname != self.originalNickname || isProfileImageChanged)
            }
            .eraseToAnyPublisher()
    }

    init(
        fetchCurrentUserUseCase: FetchCurrentUserUseCase,
        updateUserProfileUseCase: UpdateUserProfileUseCase,
        onUserUpdated: @escaping (User) -> Void
    ) {
        self.fetchCurrentUserUseCase = fetchCurrentUserUseCase
        self.updateUserProfileUseCase = updateUserProfileUseCase
        self.onUserUpdated = onUserUpdated
        setupBindings()
    }

    func loadInfo() async {
        guard !hasLoaded, !isLoadInProgress else { return }
        isLoadInProgress = true
        isLoading = true
        defer {
            isLoadInProgress = false
            isLoading = false
        }

        do {
            let user = try await fetchCurrentUserUseCase.execute()
            applyInitialUser(user)
            hasLoaded = true
        } catch is CancellationError {
            return
        } catch {
            self.error = ErrorHelper.categorize(error)
        }
    }

    func resetNickname() {
        guard let previousNickname else { return }
        nickname = previousNickname
    }

    func setPreviousNickname() {
        previousNickname = nickname
    }

    func setProfileImage(with imageData: Data?) {
        profileImageData = imageData
        profileImageURL = nil
        shouldUseDefaultProfileImage = imageData == nil
        isProfileImageChanged = true
    }

    func updateUserProfile() async {
        do {
            let user = try await updateUserProfileUseCase.execute(
                nickname: nickname == originalNickname ? nil : nickname,
                image: profileImageData,
                changeToDefaultImage: shouldUseDefaultProfileImage
            )
            onUserUpdated(user)
            shouldDismiss = true
        } catch NetworkError.conflict {
            showToast()
        } catch {
            self.error = ErrorHelper.categorize(error)
        }
    }

    private func applyInitialUser(_ user: User) {
        originalNickname = user.nickname
        previousNickname = user.nickname
        nickname = user.nickname ?? ""
        if !isProfileImageChanged {
            profileImageURL = user.profileUrl
            profileImageData = nil
            shouldUseDefaultProfileImage = false
        }
    }

    private func showToast() {
        toastWorkItem?.cancel()
        showNicknameExistsToast = true

        let workItem = DispatchWorkItem { [weak self] in
            self?.showNicknameExistsToast = false
        }
        toastWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8, execute: workItem)
    }

    private func setupBindings() {
        doneButtonEnabledPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.enableDoneButton, on: self)
            .store(in: &cancellables)
    }
}
