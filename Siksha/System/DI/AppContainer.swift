//
//  AppContainer.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

final class AppContainer {
    static let shared = AppContainer()

    let domain: RepositoryProvider
    let useCases: UseCaseProvider
    let socialLoginService: SocialLoginService
    let menuAlarmNotificationManager: MenuAlarmNotificationManaging

    init() {
        let networkModule = AlamofireNetworking()
        let repository = Repository(networkModule: networkModule)
        let domain = RepositoryProvider(repository: repository)
        let pushMessagingTokenService = FirebaseMessagingServiceImpl()
        let useCases = UseCaseProvider(
            pushMessagingTokenService: pushMessagingTokenService
        )

        self.domain = domain
        self.useCases = useCases
        self.socialLoginService = SocialLoginServiceImpl()
        self.menuAlarmNotificationManager = DefaultMenuAlarmNotificationManager(
            messagingTokenService: pushMessagingTokenService,
            registerUserDeviceUseCase: useCases.registerUserDeviceUseCase
        )
    }
}
