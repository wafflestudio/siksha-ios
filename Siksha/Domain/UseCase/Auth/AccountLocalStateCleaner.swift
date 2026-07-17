//
//  AccountLocalStateCleaner.swift
//  Siksha
//
//  Created by Codex on 7/13/26.
//

protocol AccountLocalStateCleaner {
    func execute() async
}

final class DefaultAccountLocalStateCleaner: AccountLocalStateCleaner {
    private let messagingTokenService: PushMessagingTokenServiceProtocol
    private let deviceTokenRepository: DeviceTokenRepositoryProtocol
    private let authRepository: AuthRepositoryProtocol
    private let menuAlarmPreferenceRepository: MenuAlarmPreferenceRepositoryProtocol
    private let personalRestaurantStateRepository: PersonalRestaurantStateRepositoryProtocol

    init(
        messagingTokenService: PushMessagingTokenServiceProtocol,
        deviceTokenRepository: DeviceTokenRepositoryProtocol,
        authRepository: AuthRepositoryProtocol,
        menuAlarmPreferenceRepository: MenuAlarmPreferenceRepositoryProtocol,
        personalRestaurantStateRepository: PersonalRestaurantStateRepositoryProtocol
    ) {
        self.messagingTokenService = messagingTokenService
        self.deviceTokenRepository = deviceTokenRepository
        self.authRepository = authRepository
        self.menuAlarmPreferenceRepository = menuAlarmPreferenceRepository
        self.personalRestaurantStateRepository = personalRestaurantStateRepository
    }

    func execute() async {
        try? await messagingTokenService.deleteToken()
        deviceTokenRepository.clearDeviceToken()
        authRepository.clearSession()
        menuAlarmPreferenceRepository.setAlarmEnabled(false)
        personalRestaurantStateRepository.clearPersonalRestaurants()
    }
}
