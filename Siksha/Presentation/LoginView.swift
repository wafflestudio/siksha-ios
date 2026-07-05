//
//  LoginView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/21.
//

import SwiftUI
import UIKit

struct LoginView: View {
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?

    @StateObject private var viewModel: LoginViewModel

    init(
        viewModel: LoginViewModel = LoginViewModel(
            loginUseCase: AppContainer.shared.useCases.loginUseCase,
            socialLoginService: AppContainer.shared.socialLoginService
        )
    ) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Spacer()

                    Image(.Logos.sikshaSplash)
                        .resizable()
                        .frame(width: 85.5, height: 49.5)

                    Spacer()

                    VStack(spacing: 10) {
                        Button(action: {
                            login(provider: .kakao)
                        }) {
                            Image(.Images.Login.kakaoButton)
                                .frame(width: 300, height: 45)
                                .foregroundColor(.black)
                                .cornerRadius(5.5)
                        }

                        Button(action: {
                            login(provider: .google)
                        }) {
                            Image(.Images.Login.googleButton)
                                .frame(width: 300, height: 45)
                                .foregroundColor(.black)
                                .cornerRadius(5.5)
                        }

                        Button(action: {
                            login(provider: .apple)
                        }, label: {
                            Image(.Images.Login.appleButton)
                                .frame(width: 300, height: 45)
                                .foregroundColor(.black)
                                .cornerRadius(5.5)
                        })

                        #if DEBUG

                        Button(action: {
                            loginForTest()
                        }, label: {
                            Text("테스트 로그인")
                        })

                        #endif
                    }
                    .disabled(viewModel.isLoggingIn)

                    Spacer()
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height + geometry.safeAreaInsets.bottom + geometry.safeAreaInsets.top)
            .padding(.top, -geometry.safeAreaInsets.top)
            .background(Color("Color/Foundation/Orange/500"))
            .alert(isPresented: $viewModel.signInFailed, content: {
                Alert(title: Text("로그인"), message: Text("로그인을 실패했습니다. 다시 시도해주세요."), dismissButton: .default(Text("확인")))
            })
            .onAppear {
                viewModel.onSignedIn = presentMenu
            }
        }
        .edgesIgnoringSafeArea(.all)
    }

    private func login(provider: LoginProvider) {
        Task {
            await viewModel.login(
                provider: provider,
                presentingViewController: viewControllerHolder
            )
        }
    }

    private func loginForTest() {
        Task {
            await viewModel.loginForTest()
        }
    }

    private func presentMenu() {
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
