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

class LoginViewModel: NSObject, ObservableObject, ASAuthorizationControllerDelegate, GIDSignInDelegate {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var kakaoIdToken: String? = nil
    @Published var signInFailed: Bool = false
    
    var onSignedIn: () -> Void = {}
    
    override init() {
        super.init()
        
        $kakaoIdToken
            .sink { [weak self] token in
                guard let self = self, let token = token else {
                    return
                }
                
                self.getTokenFromKakao(token: token)
            }
            .store(in: &cancellables)
    }
    
    func requestTokenToSikshaAPI(token: String, endPoint: String) {
        let url = Config.shared.baseURL + "/auth/login/" + endPoint
        
        guard var request = try? URLRequest(url: URL(string: url)!, method: .post) else {
            self.signInFailed = true
            return
        }
        print(token)
        request.setValue("Bearer " + token, forHTTPHeaderField: "\(endPoint)-token")
        
        URLSession.shared.dataTaskPublisher(for: request)
            .receive(on: RunLoop.main)
            .sink { [weak self] completion in
                guard let self = self else { return }
                if case .failure = completion {
                    self.signInFailed = true
                }
            } receiveValue: { [weak self] (data, response) in
                guard let self = self else { return }
                guard let response = response as? HTTPURLResponse,
                      200..<300 ~= response.statusCode,
                      let accessToken = try? JSON(data: data)["access_token"].stringValue,
                      let expDate = Utils.shared.decode(jwtToken: accessToken)["exp"] as? Double else {
                    self.signInFailed = true
                    return
                }

                print(expDate)
                print(accessToken)
                
                UserDefaults.standard.set(expDate, forKey: "tokenExpDate")
                UserDefaults.standard.set(accessToken, forKey: "accessToken")
                
                self.onSignedIn()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Google Sign in
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }

        let idToken = user.authentication.idToken ?? "" // Safe to send to the server
        
        requestTokenToSikshaAPI(token: idToken, endPoint: "google")
    }
    
    // MARK: - Kakao Sign in
    
    func getTokenFromKakao(token: String) {
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
