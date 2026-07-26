//
//  MenuAlarmNotificationManager.swift
//  Siksha
//
//  Created by Codex on 6/30/26.
//

import UIKit
import UserNotifications

@MainActor
final class DefaultMenuAlarmNotificationManager: MenuAlarmNotificationManaging {
    private let messagingTokenService: PushMessagingTokenServiceProtocol
    private let registerUserDeviceUseCase: RegisterUserDeviceUseCase
    private var registrationTask: Task<Void, Never>?

    init(
        messagingTokenService: PushMessagingTokenServiceProtocol,
        registerUserDeviceUseCase: RegisterUserDeviceUseCase
    ) {
        self.messagingTokenService = messagingTokenService
        self.registerUserDeviceUseCase = registerUserDeviceUseCase
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
        UIApplication.shared.registerForRemoteNotifications()
    }

    func didRegisterForRemoteNotifications(with deviceToken: Data) {
        messagingTokenService.setAPNSToken(deviceToken)

        guard registrationTask == nil else {
            return
        }

        registrationTask = Task { [weak self] in
            guard let self else { return }
            defer { registrationTask = nil }

            do {
                let token = try await messagingTokenService.fetchToken()
                try await registerUserDeviceUseCase.execute(fcmToken: token)
            } catch {
                // Registration remains retryable on the next APNs callback.
            }
        }
    }

    func didFailToRegisterForRemoteNotifications(error: Error) {
        // A later app launch or alarm-enable action will request registration again.
    }
}
