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
    
    init() {
        let networkModule = AlamofireNetworking()
        let repository = Repository(networkModule: networkModule)
        self.domain = RepositoryProvider(repository: repository)
        self.useCases = UseCaseProvider()
    }
}
