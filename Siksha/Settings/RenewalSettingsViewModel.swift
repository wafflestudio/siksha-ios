//
//  RenewalSettingsViewModel.swift
//  Siksha
//
//  Created by 김령교 on 3/3/24.
//

import Foundation
import Combine
import SwiftyJSON

class RenewalSettingsViewModel: ObservableObject {
    private var cancellables = Set<AnyCancellable>()
    
    private let repository: UserRepositoryProtocol = DomainManager.shared.domain.userRepository
    
    @Published var error: AppError?

    @Published var noMenuHide = false
  
    @Published var networkStatus: NetworkStatus = .idle
    @Published var showSignOutAlert: Bool = false
    @Published var showRemoveAccountAlert: Bool = false
    @Published var removeAccountFailed: Bool = false
    
    @Published var version: String = ""
    @Published var appStoreVersion: String = ""
   
    @Published var showVOC: Bool = false
    @Published var postVOCStatus: NetworkStatus = .idle
    @Published var userId: Int = 0
    @Published var vocComment: String = ""
    @Published var alertMessage: String = ""
    @Published var showAlert: Bool = false
    
    
    func getVersion() {
        guard let dictionary = Bundle.main.infoDictionary,
            let version = dictionary["CFBundleShortVersionString"] as? String else {
            return
        }
        self.version = version
    }
    
    func loadInfo() {
        UserManager.shared.loadUserInfo()
    }
    
    func getAppStoreVersion() {
        guard let url = URL(string: "http://itunes.apple.com/lookup?id=1032700617"),
            let data = try? Data(contentsOf: url),
            let json = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
            let results = json["results"] as? [[String: Any]],
            results.count > 0,
            let appStoreVersion = results[0]["version"] as? String
            else { return }
        self.appStoreVersion = appStoreVersion
    }
    
    var isUpdateAvailable: Bool {
        if self.version == self.appStoreVersion && self.version != "" {
            return false
        } else {
            return true
        }
    }
    
    init() {
        noMenuHide = !UserDefaults.standard.bool(forKey: "notNoMenuHide")
        
        getUserId()
        getVersion()
        getAppStoreVersion()
        loadInfo()
        
        $noMenuHide
            .sink { hide in
                UserDefaults.standard.set(!hide, forKey: "notNoMenuHide")
            }
            .store(in: &cancellables)
         
        $postVOCStatus
            .dropFirst()
            .sink { [weak self] status in
                guard let self = self else { return }
                
                self.alertMessage = status == .failed ? "전송에 실패했습니다. 다시 시도해주세요." : "전송했습니다."
                self.showAlert = true
            }
            .store(in: &cancellables)
    }
    
    
    func getUserId() {
        repository.loadUserInfo()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: { [weak self] user in
                self?.userId = user.id
            })
            .store(in: &cancellables)
    }
    
    func sendVOC() {
        repository.submitVOC(comment: vocComment, platform: "iOS")
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                switch completionStatus {
                case .finished:
                    self?.postVOCStatus = .succeeded
                case .failure(let error):
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: { value in
                
            })
            .store(in: &cancellables)
    }
    
    func logOutAccount() {
        UserDefaults.standard.set(nil, forKey: "accessToken")
    }
    
    func removeAccount(completion: @escaping (Bool) -> Void) {
        guard let accessToken = UserDefaults.standard.string(forKey: "accessToken") else {
            removeAccountFailed = true
            return
        }
        repository.deleteUser()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                switch completionStatus {
                case .finished:
                    UserDefaults.standard.set(nil, forKey: "accessToken")
                    completion(true)
                case .failure(let error):
                    self?.error = ErrorHelper.categorize(error)
                    completion(false)
                }
            }, receiveValue: { value in
                
            })
            .store(in: &cancellables)
    }
}

