//
//  SocialLoginService.swift
//  Siksha
//
//  Created by Codex on 7/5/26.
//

import AuthenticationServices
import Foundation
import GoogleSignIn
import KakaoSDKAuth
import KakaoSDKUser
import UIKit

protocol SocialLoginService: AnyObject {
    @MainActor
    func login(
        provider: LoginProvider,
        presentingViewController: UIViewController?
    ) async throws -> LoginCredential
    @MainActor
    func handleOpenURL(_ url: URL) -> Bool
}

enum SocialLoginServiceError: Error {
    case missingPresentingViewController
    case missingCredential
}

final class SocialLoginServiceImpl: SocialLoginService {
    private var appleAuthorizationCoordinator: AppleAuthorizationCoordinator?

    @MainActor
    func login(
        provider: LoginProvider,
        presentingViewController: UIViewController?
    ) async throws -> LoginCredential {
        switch provider {
        case .kakao:
            return try await loginWithKakao()
        case .google:
            return try await loginWithGoogle(presentingViewController: presentingViewController)
        case .apple:
            return try await loginWithApple(presentingViewController: presentingViewController)
        }
    }

    @MainActor
    func handleOpenURL(_ url: URL) -> Bool {
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }

        return GIDSignIn.sharedInstance.handle(url)
    }

    @MainActor
    private func loginWithKakao() async throws -> LoginCredential {
        let oauthToken = try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<OAuthToken, Error>) in
            let completion: (OAuthToken?, Error?) -> Void = { oauthToken, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let oauthToken else {
                    continuation.resume(throwing: SocialLoginServiceError.missingCredential)
                    return
                }

                continuation.resume(returning: oauthToken)
            }

            if UserApi.isKakaoTalkLoginAvailable() {
                UserApi.shared.loginWithKakaoTalk(completion: completion)
            } else {
                UserApi.shared.loginWithKakaoAccount(completion: completion)
            }
        }

        return LoginCredential(provider: .kakao, token: oauthToken.accessToken)
    }

    @MainActor
    private func loginWithGoogle(
        presentingViewController: UIViewController?
    ) async throws -> LoginCredential {
        guard let presentingViewController else {
            throw SocialLoginServiceError.missingPresentingViewController
        }

        let signInResult = try await GIDSignIn.sharedInstance.signIn(
            withPresenting: presentingViewController
        )

        guard let token = signInResult.user.idToken?.tokenString else {
            throw SocialLoginServiceError.missingCredential
        }

        return LoginCredential(provider: .google, token: token)
    }

    @MainActor
    private func loginWithApple(
        presentingViewController: UIViewController?
    ) async throws -> LoginCredential {
        let coordinator = AppleAuthorizationCoordinator(
            presentingViewController: presentingViewController
        )
        appleAuthorizationCoordinator = coordinator
        defer {
            appleAuthorizationCoordinator = nil
        }

        return try await coordinator.perform()
    }
}

@MainActor
private final class AppleAuthorizationCoordinator: NSObject {
    private weak var presentingViewController: UIViewController?
    private var continuation: CheckedContinuation<LoginCredential, Error>?

    init(presentingViewController: UIViewController?) {
        self.presentingViewController = presentingViewController
    }

    func perform() async throws -> LoginCredential {
        try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation

            let provider = ASAuthorizationAppleIDProvider()
            let request = provider.createRequest()
            request.requestedScopes = [.fullName, .email]

            let authorizationController = ASAuthorizationController(
                authorizationRequests: [request]
            )
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        }
    }

    private func complete(with result: Result<LoginCredential, Error>) {
        guard let continuation else {
            return
        }

        self.continuation = nil

        switch result {
        case .success(let credential):
            continuation.resume(returning: credential)
        case .failure(let error):
            continuation.resume(throwing: error)
        }
    }
}

extension AppleAuthorizationCoordinator: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential,
            let tokenData = appleIDCredential.identityToken,
            let token = String(data: tokenData, encoding: .utf8)
        else {
            complete(with: .failure(SocialLoginServiceError.missingCredential))
            return
        }

        complete(
            with: .success(
                LoginCredential(
                    provider: .apple,
                    token: token,
                    appleUserIdentifier: appleIDCredential.user
                )
            )
        )
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        complete(with: .failure(error))
    }
}

extension AppleAuthorizationCoordinator: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        if let window = presentingViewController?.view.window {
            return window
        }

        if let keyWindow = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)
        {
            return keyWindow
        }

        return ASPresentationAnchor()
    }
}
