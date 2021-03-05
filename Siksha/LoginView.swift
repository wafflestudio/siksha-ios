//
//  SplashView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/21.
//

import SwiftUI
import AuthenticationServices
import KakaoSDKAuth
import GoogleSignIn

struct LoginView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @EnvironmentObject var appState: AppState
    
    @ObservedObject var viewModel = LoginViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("LaunchBackground")
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.height + geometry.safeAreaInsets.bottom + geometry.safeAreaInsets.top)
                    .padding(.top, -geometry.safeAreaInsets.top)
                
                
                VStack {
                    Spacer()
                    
                    Image("LaunchLogo")
                        .frame(width: 100, height: 100)
                    
                    Spacer()
                    
                    VStack(spacing: 5) {
                        Button(action : {
                            handleKakaoLogin()
                        }){
                            HStack {
                                Image("KakaoLogo")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .padding(.leading, 15)
                                Text("카카오톡으로 로그인")
                                    .font(.system(size: 15, weight: .semibold))
                                    .padding(.leading, 15)
                                
                                Spacer()
                            }
                            .frame(width: 220, height: 40)
                            .foregroundColor(.black)
                            .background(Color.init(red: 254/255, green: 229/255, blue: 0))
                            .cornerRadius(5.5)
                        }
                        
                        Button(action : {
                            handleGoogleLogin()
                        }){
                            HStack {
                                Image("GoogleLogo")
                                    .resizable()
                                    .frame(width: 18, height: 18)
                                    .padding(.leading, 15)
                                Text("Google로 로그인")
                                    .font(.system(size: 15, weight: .semibold))
                                    .padding(.leading, 15)
                                
                                Spacer()
                            }
                            .frame(width: 220, height: 40)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(5.5)
                        }
                        
                        Button(action: {
                            handleAppleLogin()
                        }, label: {
                            HStack {
                                Image(systemName: "applelogo")
                                    .font(.system(size: 17))
                                    .padding(.leading, 16)
                                Text("Apple로 로그인")
                                    .font(.system(size: 15, weight: .semibold))
                                    .padding(.leading, 16)
                                
                                Spacer()
                            }
                            .frame(width: 220, height: 40)
                            .foregroundColor(.black)
                            .background(Color.white)
                            .cornerRadius(5.5)
                        })
                    }
                    
                    Spacer()
                    
                    Image("WaffleStudio")
                        .resizable()
                        .frame(width: 180, height: 10)
                        .padding(.bottom, 55 + geometry.safeAreaInsets.bottom)
                }
            }
            .alert(isPresented: $viewModel.signInFailed, content: {
                Alert(title: Text("로그인"), message: Text("로그인을 실패했습니다. 다시 시도해주세요."), dismissButton: .default(Text("확인")))
            })
            .onAppear {
                viewModel.onSignedIn = presentMenu
            }
        }
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
        if (AuthApi.isKakaoTalkLoginAvailable()) {
            AuthApi.shared.loginWithKakaoTalk(completion: self.handleKakaoLoginResponse)
        } else {
            // Login through Safari
            AuthApi.shared.loginWithKakaoAccount(completion: self.handleKakaoLoginResponse)
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
        if GIDSignIn.sharedInstance()?.presentingViewController==nil {
            GIDSignIn.sharedInstance()?.presentingViewController = UIApplication.shared.windows.last?.rootViewController
        }
        GIDSignIn.sharedInstance()?.delegate = viewModel
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    func presentMenu() {
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
