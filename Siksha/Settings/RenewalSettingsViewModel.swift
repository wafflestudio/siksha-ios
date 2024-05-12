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
    
    @Published var noMenuHide = false
  
    @Published var networkStatus: NetworkStatus = .idle
    @Published var showSignOutAlert: Bool = false
    
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
        Networking.shared.getUserInfo()
            .receive(on: RunLoop.main)
            .map(\.value?.id)
            .replaceNil(with: 0)
            .assign(to: \.userId, on: self)
            .store(in: &cancellables)
    }
    
    func sendVOC() {
        Networking.shared.submitVOC(comment: vocComment, platform: "iOS")
            .receive(on: RunLoop.main)
            .sink { [weak self] result in
                guard let self = self else { return }
                
                guard let response = result.response,
                      200..<300 ~= response.statusCode else {
                    self.postVOCStatus = .failed
                    return
                }
                
                self.postVOCStatus = .succeeded
            }
            .store(in: &cancellables)
    }
}

