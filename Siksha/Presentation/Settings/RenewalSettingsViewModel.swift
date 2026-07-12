//
//  RenewalSettingsViewModel.swift
//  Siksha
//
//  Created by 김령교 on 3/3/24.
//

import Combine
import FirebaseMessaging
import Foundation

@MainActor
final class RenewalSettingsViewModel: ObservableObject {
    @Published var error: AppError?
    @Published var noMenuHide = false
    @Published var networkStatus: NetworkStatus = .idle
    @Published var showSignOutAlert = false
    @Published var showRemoveAccountAlert = false
    @Published var removeAccountFailed = false
    @Published var logoutFailed = false
    @Published var version: String
    @Published var appStoreVersion = ""
    @Published var showVOC = false
    @Published var postVOCStatus: NetworkStatus = .idle
    @Published private(set) var user: User?
    @Published var userId = 0
    @Published var vocComment = ""
    @Published var alertMessage = ""
    @Published var showAlert = false

    private let repository: LegacyUserRepositoryProtocol
    private let authRepository: LegacyAuthRepositoryProtocol
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
        repository: LegacyUserRepositoryProtocol = AppContainer.shared.domain.userRepository,
        authRepository: LegacyAuthRepositoryProtocol = AppContainer.shared.domain.authRepository,
        version: String = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
    ) {
        self.manageRestaurantsWithoutMenuVisibilityUseCase = manageRestaurantsWithoutMenuVisibilityUseCase
        self.fetchCurrentUserUseCase = fetchCurrentUserUseCase
        self.submitVOCUseCase = submitVOCUseCase
        self.fetchAppStoreVersionUseCase = fetchAppStoreVersionUseCase
        self.repository = repository
        self.authRepository = authRepository
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

    func logOutAccount(completion:@escaping(Bool)->()) {
        if UserDefaults.standard.string(forKey: "fcmToken") == nil{
            UserDefaults.standard.removeObject(forKey: "accessToken")
            UserDefaults.standard.set(false,forKey: "isAlarmEnabled")
            completion(true)
        }
        else{
            authRepository.deleteUserDevice(fcmToken: UserDefaults.standard.string(forKey: "fcmToken")!)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] completionStatus in
                    switch completionStatus {
                    case .finished:
                        print("delete success fcm")
                        Messaging.messaging().deleteToken { error in
                            if let error = error {
                                print("Failed to delete FCM token:", error)
                                print(error)
                                self?.error = ErrorHelper.categorize(error)
                                self?.logoutFailed = true
                                completion(false)
                            }
                            else{
                                print("delete done")
                                UserDefaults.standard.removeObject(forKey: "fcmToken")
                                UserDefaults.standard.removeObject(forKey: "accessToken")
                                UserDefaults.standard.removeObject( forKey: "alreadySentFCM")
                                UserDefaults.standard.set(false,forKey: "isAlarmEnabled")
                                completion(true)
                            }
                        }
                    case .failure(let error):
                        print("delete fail fcm")
                        print(error)
                        self?.error = ErrorHelper.categorize(error)
                        self?.logoutFailed = true
                        completion(false)
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        }
    }

    func removeAccount(completion: @escaping (Bool) -> Void) {
        guard UserDefaults.standard.string(forKey: "accessToken") != nil else {
            removeAccountFailed = true
            return
        }
        repository.deleteUser()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                switch completionStatus {
                case .finished:
                    Utils.shared.removeAllUserDefaults()
                    completion(true)
                case .failure(let error):
                    self?.error = ErrorHelper.categorize(error)
                    completion(false)
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
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
