//
//  SceneDelegate.swift
//  Siksha
//
//  Created by 박종석 on 2021/01/31.
//

import UIKit
import SwiftUI
import AuthenticationServices
import KakaoSDKAuth
import GoogleSignIn

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            } else {
                _ = GIDSignIn.sharedInstance.handle(url)
            }
        }
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Create the SwiftUI view that provides the window contents.
        
        let appleUserIdentifier = UserDefaults.standard.string(forKey: "appleUserIdentifier")
        var accessToken = UserDefaults.standard.string(forKey: "accessToken")
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        
        if UserDefaults.standard.bool(forKey: "signedInWithApple") {
            if let identifier = appleUserIdentifier {
                appleIDProvider.getCredentialState(forUserID: appleUserIdentifier ?? "") { (credentialState, error) in
                    switch credentialState {
                    case .authorized:
                        break // The Apple ID credential is valid.
                    case .revoked, .notFound:
                        accessToken = nil
                        UserDefaults.standard.removeObject(forKey:  "userToken")
                    default:
                        break
                    }
                }
            } else {
                accessToken = nil
                UserDefaults.standard.removeObject(forKey:  "userToken")
            }
        }

        // Navigation Bar 배경색 세팅
        UINavigationBar.changeBackgroundColor(color: UIColor(named: "Orange500") ?? .clear)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            if accessToken != nil {
                print(accessToken!)
                let appState = AppState()
                let contentView = ContentView().environmentObject(appState)
                window.rootViewController = UIHostingController(rootView: contentView)
            } else {
                window.rootViewController = UIHostingController(rootView: LoginView())
            }
            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

