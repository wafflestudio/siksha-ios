//
//  Domain.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

final class RepositoryProvider {
    private let repository: CommunityRepositoryProtocol
    
    init(repository: CommunityRepositoryProtocol) {
        self.repository = repository
    }
    
    var communityRepository: CommunityRepositoryProtocol {
        return self.repository
    }
}
