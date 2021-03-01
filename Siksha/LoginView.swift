//
//  SplashView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/21.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @EnvironmentObject var appState: AppState
    
    @State var signInDelegate: AppleSignInDelegate! = nil
    @State var signInFailed: Bool = false
    
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

                    Button(action: {
                        handleAuthorizationAppleIDButtonPress()
                    }, label: {
                        HStack {
                            Image(systemName: "applelogo")
                                .font(.system(size: 12))
                            Text("Apple로 로그인")
                                .font(.system(size: 15, weight: .semibold))
                        }
                        .frame(width: 200, height: 40)
                        .foregroundColor(.black)
                        .background(Color.white)
                        .cornerRadius(5.5)
                    })
                    
                    
                    Spacer()
                    
                    Image("WaffleStudio")
                        .resizable()
                        .frame(width: 180, height: 10)
                        .padding(.bottom, 55 + geometry.safeAreaInsets.bottom)
                }
            }
            .alert(isPresented: $signInFailed, content: {
                Alert(title: Text("로그인"), message: Text("로그인을 실패했습니다. 다시 시도해주세요."), dismissButton: .default(Text("확인")))
            })
        }
    }
    
    func handleAuthorizationAppleIDButtonPress() {
        signInDelegate = AppleSignInDelegate {
            viewControllerHolder?.present(style: .fullScreen) {
                ContentView().environmentObject(appState)
            }
        } onFailed: {
            self.signInFailed = true
        }
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        
        authorizationController.delegate = signInDelegate
        authorizationController.performRequests()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
