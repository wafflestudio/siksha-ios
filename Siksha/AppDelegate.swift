//
//  AppDelegate.swift
//  Siksha
//
//  Created by 박종석 on 2021/01/31.
//

import UIKit
import KakaoSDKCommon
import Firebase
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        #if DEBUG
            print("debug")
            let infoName = "GoogleService-Info-dev"
            let configKey = "debug"
        #else
            let infoName = "GoogleService-Info"
            let configKey = "release"
        #endif
        
        let dictPath = Bundle.main.path(forResource: "config", ofType: "plist")
        let configDict = NSDictionary(contentsOfFile: dictPath!)!.object(forKey: configKey) as! NSDictionary
        
        let firebasePath = Bundle.main.path(forResource: infoName, ofType: "plist")
        let firebaseOption = FirebaseOptions(contentsOfFile: firebasePath!)
        
        FirebaseApp.configure(options: firebaseOption!)
        
        Config.shared.baseURL = (configDict.object(forKey: "server_url") as! String)
        
        let googleClientId = configDict.object(forKey: "google_client_id") as! String
        let kakaoAppKey = configDict.object(forKey: "kakao_app_key") as! String
        
        GIDSignIn.sharedInstance()?.clientID = googleClientId
        
        KakaoSDKCommon.initSDK(appKey: kakaoAppKey)

        return true
    }
    
    @available(iOS 9.0, *)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance().handle(url)
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
                
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

