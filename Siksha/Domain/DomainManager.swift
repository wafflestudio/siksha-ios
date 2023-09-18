//
//  DomainManager.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

final class DomainManager {
    static let shared = DomainManager()
    
    let domain: Domain
    
    init() {
        let networkModule = AlamofireNetworking()
        let repository = Repository(networkModule: networkModule)
        self.domain = Domain(repository: repository)
    }
}
