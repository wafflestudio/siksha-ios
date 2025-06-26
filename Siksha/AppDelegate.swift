//
//  AppDelegate.swift
//  Siksha
//
//  Created by 박종석 on 2021/01/31.
//

import UIKit
import KakaoSDKCommon
import GoogleSignIn
import NMapsMap
import RealmSwift
import FirebaseCore
import Mixpanel

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let googleClientId = Config.shared.googleClientId
        let naverMapClientId = Config.shared.naverMapClientId
        let kakaoAppKey = Config.shared.kakaoAppKey
        
        NMFAuthManager.shared().clientId = naverMapClientId
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: googleClientId)

        FirebaseApp.configure()
        
        KakaoSDK.initSDK(appKey: kakaoAppKey)
        setupMixpanel()
        
        let config = Realm.Configuration(
            schemaVersion: 2, // 새로운 스키마 버전 설정
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 2 {
                    // 1-1. 마이그레이션 수행
                    migration.enumerateObjects(ofType: Meal.className()) { oldObject, newObject in
                        newObject!["isLiked"] = false // Provide a default value for 'isLiked'
                        newObject!["likeCnt"] = 0 // Provide a default value for 'likeCnt'
                    }
                }
            }
        )
                
        // 2. Realm이 새로운 Object를 쓸 수 있도록 설정
        Realm.Configuration.defaultConfiguration = config

        // Feature Flag
        FeatureFlag.shared.enable(feature: .community)
        
        UserManager.shared.loadUserInfo()
        
        return true
    }
    
    private func setupMixpanel() {
        let mixpanelToken = Config.shared.mixpanelToken
        
        Mixpanel.initialize(
            token: mixpanelToken,
            trackAutomaticEvents: false
        )
        
        #if DEBUG
        Mixpanel.mainInstance().loggingEnabled = true
        #endif
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

