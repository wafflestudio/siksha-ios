//
//  AppleSignInDelegate.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/21.
//

import Foundation
import AuthenticationServices
import Combine
import SwiftyJSON

class AppleSignInDelegate: NSObject, ASAuthorizationControllerDelegate {
    private let signInSucceeded: () -> Void
    private let signInFailed: () -> Void
    private var cancellables = Set<AnyCancellable>()
    
    init(onSignedIn: @escaping () -> Void, onFailed: @escaping () -> Void) {
        self.signInSucceeded = onSignedIn
        
        self.signInFailed = onFailed
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let token = appleIDCredential.identityToken
            
            UserDefaults.standard.set(userIdentifier, forKey: "appleUserIdentifier")
            
            print(String(decoding: token!, as: UTF8.self))
            
            let url = "-"
            
            var request = URLRequest(url: URL(string: url)!)
            request.httpMethod = "POST"
            request.setValue("Bearer " + String(decoding: token!, as: UTF8.self), forHTTPHeaderField: "authorization-token")
            
            URLSession.shared.dataTaskPublisher(for: request)
                .receive(on: RunLoop.main)
                .sink { [weak self] completion in
                    guard let self = self else { return }
                    if case .failure = completion {
                        self.signInFailed()
                    }
                } receiveValue: { [weak self] (data, response) in
                    guard let self = self else { return }
                    guard let response = response as? HTTPURLResponse,
                          200..<300 ~= response.statusCode,
                          let accessToken = try? JSON(data: data)["access_token"].stringValue,
                          let expDate = Utils.shared.decode(jwtToken: accessToken)["exp"] as? Double else {
                        self.signInFailed()
                        return
                    }

                    print(expDate)
                    print(accessToken)
                    
                    UserDefaults.standard.set(expDate, forKey: "tokenExpDate")
                    UserDefaults.standard.set(accessToken, forKey: "accessToken")
                    
                    self.signInSucceeded()
                }
                .store(in: &cancellables)
        default:
            break
        }
    }
}
