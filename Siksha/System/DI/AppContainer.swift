//
//  AppContainer.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

@MainActor
final class AppContainer {
    static let shared = AppContainer()

    let domain: RepositoryProvider
    let useCases: UseCaseProvider
    let socialLoginService: SocialLoginService
    let menuAlarmNotificationManager: MenuAlarmNotificationManaging
    let imageCache: ImageCache
    let blockManager: BlockManager

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
        self.imageCache = TemporaryImageCache()
        self.blockManager = BlockManager()
        self.menuAlarmNotificationManager = DefaultMenuAlarmNotificationManager(
            messagingTokenService: pushMessagingTokenService,
            registerUserDeviceUseCase: useCases.registerUserDeviceUseCase
        )
    }
}
