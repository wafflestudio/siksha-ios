//
//  Domain.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

import Foundation

protocol DomainProtocol {
    var communityRepository: CommunityRepositoryProtocol { get }
}

final class Domain: DomainProtocol {
    private let repository: RepositoryProtocol
    
    init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    var communityRepository: CommunityRepositoryProtocol {
        return self.repository
    }
}
