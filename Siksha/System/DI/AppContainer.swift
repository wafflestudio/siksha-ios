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
    let menuAlarmNotificationManager: DefaultMenuAlarmNotificationManager
    
    init() {
        let networkModule = AlamofireNetworking()
        let repository = Repository(networkModule: networkModule)
        let domain = RepositoryProvider(repository: repository)
        
        self.domain = domain
        self.useCases = UseCaseProvider()
        self.socialLoginService = SocialLoginServiceImpl()
        self.menuAlarmNotificationManager = DefaultMenuAlarmNotificationManager(
            authRepository: domain.authRepository
        )
    }
}
