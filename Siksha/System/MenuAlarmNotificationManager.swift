//
//  MenuAlarmNotificationManager.swift
//  Siksha
//
//  Created by Codex on 6/30/26.
//

import UIKit
import UserNotifications
import FirebaseMessaging
import Combine

final class DefaultMenuAlarmNotificationManager: MenuAlarmNotificationManaging {
    private let authRepository: AuthRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    private var isSendingFCMToken = false
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }
    
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions) { isGranted, _ in
                continuation.resume(returning: isGranted)
            }
        }
    }
    
    func registerRemoteNotificationsIfNeeded() {
        guard !UserDefaults.standard.bool(forKey: "alreadySentFCM") else {
            return
        }
        
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func didRegisterForRemoteNotifications(with deviceToken: Data) {
        guard !UserDefaults.standard.bool(forKey: "alreadySentFCM") else {
            return
        }
        
        Messaging.messaging().apnsToken = deviceToken
        Messaging.messaging().token { [weak self] token, error in
            if let error {
                print(error)
                print("Token Registration fail")
                return
            }
            
            guard let token else {
                print("Token Registration fail")
                return
            }
            
            UserDefaults.standard.set(token, forKey: "fcmToken")
            self?.sendFCMToken(token)
        }
    }
    
    func didFailToRegisterForRemoteNotifications(error: Error) {
        print(error)
        print("Token Registration fail")
    }
    
    private func sendFCMToken(_ token: String) {
        DispatchQueue.main.async { [weak self] in
            guard let self, !self.isSendingFCMToken else {
                return
            }
            
            self.isSendingFCMToken = true
            self.authRepository.postUserDevice(fcmToken: token)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] completion in
                    self?.isSendingFCMToken = false
                    
                    if case .failure(let error) = completion {
                        print(error)
                        print("Token Registration fail")
                    }
                }, receiveValue: {
                    UserDefaults.standard.set(true, forKey: "alreadySentFCM")
                    print("Token Registration success")
                })
                .store(in: &self.cancellables)
        }
    }
}
