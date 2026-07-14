//
//  RenewalSettingsViewModel.swift
//  Siksha
//
//  Created by 김령교 on 3/3/24.
//

import Combine
import Foundation

@MainActor
final class RenewalSettingsViewModel: ObservableObject {
    @Published var error: AppError?
    @Published var noMenuHide = false
    @Published var networkStatus: NetworkStatus = .idle
    @Published var version: String
    @Published var appStoreVersion = ""
    @Published var showVOC = false
    @Published var postVOCStatus: NetworkStatus = .idle
    @Published private(set) var user: User?
    @Published var userId = 0
    @Published var vocComment = ""
    @Published var alertMessage = ""
    @Published var showAlert = false

    private let manageRestaurantsWithoutMenuVisibilityUseCase: ManageRestaurantsWithoutMenuVisibilityUseCase
    private let fetchCurrentUserUseCase: FetchCurrentUserUseCase
    private let submitVOCUseCase: SubmitVOCUseCase
    private let fetchAppStoreVersionUseCase: FetchAppStoreVersionUseCase
    private var cancellables = Set<AnyCancellable>()
    private var hasLoadedUser = false
    private var hasLoadedAppStoreVersion = false
    private var isLoading = false

    var isUpdateAvailable: Bool {
        version != appStoreVersion || version.isEmpty
    }

    init(
        manageRestaurantsWithoutMenuVisibilityUseCase: ManageRestaurantsWithoutMenuVisibilityUseCase,
        fetchCurrentUserUseCase: FetchCurrentUserUseCase,
        submitVOCUseCase: SubmitVOCUseCase,
        fetchAppStoreVersionUseCase: FetchAppStoreVersionUseCase,
        version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    ) {
        self.manageRestaurantsWithoutMenuVisibilityUseCase = manageRestaurantsWithoutMenuVisibilityUseCase
        self.fetchCurrentUserUseCase = fetchCurrentUserUseCase
        self.submitVOCUseCase = submitVOCUseCase
        self.fetchAppStoreVersionUseCase = fetchAppStoreVersionUseCase
        self.version = version
        noMenuHide = manageRestaurantsWithoutMenuVisibilityUseCase.shouldHideRestaurantsWithoutMenu()

        $noMenuHide
            .dropFirst()
            .sink { [weak self] hide in
                self?.manageRestaurantsWithoutMenuVisibilityUseCase.setShouldHideRestaurantsWithoutMenu(hide)
            }
            .store(in: &cancellables)
    }

    func loadIfNeeded() async {
        guard !isLoading else { return }
        guard !hasLoadedUser || !hasLoadedAppStoreVersion else { return }
        isLoading = true
        defer { isLoading = false }

        if !hasLoadedUser {
            hasLoadedUser = await loadUser()
        }
        if !hasLoadedAppStoreVersion {
            hasLoadedAppStoreVersion = await loadAppStoreVersion()
        }
    }

    func applyUpdatedUser(_ user: User) {
        self.user = user
        userId = user.id
    }

    func sendVOC() async {
        postVOCStatus = .loading

        do {
            try await submitVOCUseCase.execute(comment: vocComment, platform: "iOS")
            postVOCStatus = .succeeded
            alertMessage = "전송했습니다."
            showAlert = true
        } catch {
            postVOCStatus = .failed
            self.error = ErrorHelper.categorize(error)
            alertMessage = "전송에 실패했습니다. 다시 시도해주세요."
            showAlert = true
        }
    }

    private func loadUser() async -> Bool {
        do {
            applyUpdatedUser(try await fetchCurrentUserUseCase.execute())
            return true
        } catch {
            self.error = ErrorHelper.categorize(error)
            return false
        }
    }

    private func loadAppStoreVersion() async -> Bool {
        do {
            appStoreVersion = try await fetchAppStoreVersionUseCase.execute().rawValue
            return true
        } catch {
            self.error = ErrorHelper.categorize(error)
            return false
        }
    }
}
