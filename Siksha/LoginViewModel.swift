//
//  LoginViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/05.
//

import Foundation
import SwiftyJSON
import GoogleSignIn
import AuthenticationServices
import Combine

@MainActor
class LoginViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var kakaoIdToken: String? = nil
    @Published var googleIdToken: String? = nil
    @Published var signInFailed: Bool = false
    
    var onSignedIn: () -> Void = {}
    
    override init() {
        super.init()
        
        $kakaoIdToken
            .sink { [weak self] token in
                guard let self = self, let token = token else {
                    return
                }
                
                self.authenticateWithKakao(token: token)
            }
            .store(in: &cancellables)
        
        $googleIdToken
            .sink { [weak self] token in
                guard let self = self, let token = token else {
                    return
                }
                
                self.authenticateWithGoogle(idToken: token)
            }
            .store(in: &cancellables)
    }
    
    func requestTokenToSikshaAPI(token: String, endPoint: String) {
        #if DEBUG
        print(token)
        #endif
        
        Networking.shared.getAccessToken(token: token, endPoint: endPoint)
            .sink { result in
                guard let data = result.value,
                      let accessToken = try? JSON(data: data)["access_token"].stringValue,
                      let expDate = Utils.shared.decode(jwtToken: accessToken)["exp"] as? Double else {
                    self.signInFailed = true
                    return
                }
                
                #if DEBUG
                print(expDate)
                print(accessToken)
                #endif
                
                UserDefaults.standard.set(expDate, forKey: "tokenExpDate")
                UserDefaults.standard.set(accessToken, forKey: "accessToken")
                
                self.onSignedIn()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Google Sign in
    
    func authenticateWithGoogle(idToken: String) {
        requestTokenToSikshaAPI(token: idToken, endPoint: "google")
    }
    
    // MARK: - Kakao Sign in
    
    func authenticateWithKakao(token: String) {
        requestTokenToSikshaAPI(token: token, endPoint: "kakao")
    }
    
    // MARK: - Apple Sign in
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // Create an account in your system.
            let userIdentifier = appleIDCredential.user
            let token = appleIDCredential.identityToken
            
            UserDefaults.standard.set(userIdentifier, forKey: "appleUserIdentifier")
            UserDefaults.standard.set(true, forKey: "signedInWithApple")
            
            print(String(decoding: token!, as: UTF8.self))
            
            requestTokenToSikshaAPI(token: String(decoding: token!, as: UTF8.self), endPoint: "apple")
        default:
            break
        }
    }
}
