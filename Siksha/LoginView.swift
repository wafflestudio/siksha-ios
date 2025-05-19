//
//  SplashView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/21.
//

import SwiftUI
import AuthenticationServices
import KakaoSDKAuth
import KakaoSDKUser
import GoogleSignIn

struct LoginView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    
    @ObservedObject var viewModel = LoginViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()
                    
                    Image("sikshaSplash")
                        .resizable()
                        .frame(width: 85.5, height: 49.5)
                    
                    Spacer()
                    
                    VStack(spacing: 10) {
                        Button(action : {
                            handleKakaoLogin()
                        }){
                            Image("kakaoButton")
                                .frame(width: 300, height: 45)
                                .foregroundColor(.black)
                                .cornerRadius(5.5)
                        }
                        
                        Button(action : {
                            handleGoogleLogin()
                        }){
                            Image("googleButton")
                                .frame(width: 300, height: 45)
                                .foregroundColor(.black)
                                .cornerRadius(5.5)
                        }
                        
                        Button(action: {
                            handleAppleLogin()
                        }, label: {
                            Image("appleButton")
                                .frame(width: 300, height: 45)
                                .foregroundColor(.black)
                                .cornerRadius(5.5)
                        })
                    }
                    
                    Spacer()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height + geometry.safeAreaInsets.bottom + geometry.safeAreaInsets.top)
            .padding(.top, -geometry.safeAreaInsets.top)
            .background(Color("Orange500"))
            .alert(isPresented: $viewModel.signInFailed, content: {
                Alert(title: Text("로그인"), message: Text("로그인을 실패했습니다. 다시 시도해주세요."), dismissButton: .default(Text("확인")))
            })
            .onAppear {
                viewModel.onSignedIn = presentMenu
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func handleAppleLogin() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = viewModel
        authorizationController.performRequests()
    }
    
    func handleKakaoLogin() {
        // checks whether KakaoTalk is installed
        if (UserApi.isKakaoTalkLoginAvailable()) {
            UserApi.shared.loginWithKakaoTalk(completion: self.handleKakaoLoginResponse)
        } else {
            // Login through Safari
            UserApi.shared.loginWithKakaoAccount(completion: self.handleKakaoLoginResponse)
        }
    }
    
    func handleKakaoLoginResponse(oauthToken: OAuthToken?, error: Error?) {
        if let oauthToken = oauthToken {
            viewModel.kakaoIdToken = oauthToken.accessToken
        } else {
            viewModel.signInFailed = true
        }
    }
    
    func handleGoogleLogin() {
        if let viewController = viewControllerHolder {
            GIDSignIn.sharedInstance()?.presentingViewController = viewController
        }
        GIDSignIn.sharedInstance()?.delegate = viewModel
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func presentMenu() {
        let appState = AppState()
        viewControllerHolder?.present(style: .fullScreen) {
            ContentView().environmentObject(appState)
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
