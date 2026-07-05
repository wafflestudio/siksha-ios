//
//  LoginViewModel.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/05.
//

import Foundation
import UIKit

final class LoginViewModel: ObservableObject {
    private let loginUseCase: LoginUseCase
    private let socialLoginService: SocialLoginService

    @Published var signInFailed: Bool = false
    @Published private(set) var isLoggingIn: Bool = false

    var onSignedIn: () -> Void = {}

    init(
        loginUseCase: LoginUseCase,
        socialLoginService: SocialLoginService
    ) {
        self.loginUseCase = loginUseCase
        self.socialLoginService = socialLoginService
    }

    @MainActor
    func login(
        provider: LoginProvider,
        presentingViewController: UIViewController?
    ) async {
        guard !isLoggingIn else {
            return
        }

        isLoggingIn = true
        defer {
            isLoggingIn = false
        }

        do {
            let credential = try await socialLoginService.login(
                provider: provider,
                presentingViewController: presentingViewController
            )
            _ = try await loginUseCase.login(with: credential)
            onSignedIn()
        } catch {
            signInFailed = true
        }
    }

    @MainActor
    func loginForTest() async {
        guard !isLoggingIn else {
            return
        }

        isLoggingIn = true
        defer {
            isLoggingIn = false
        }

        do {
            _ = try await loginUseCase.loginForTest()
            onSignedIn()
        } catch {
            signInFailed = true
        }
    }
}
