//
//  Domain.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

import Foundation

final class RepositoryProvider {
    private let repository: RepositoryProtocol
    
    init(repository: RepositoryProtocol) {
        self.repository = repository
    }
    
    var communityRepository: CommunityRepositoryProtocol {
        return self.repository
    }
    
    var userRepository: LegacyUserRepositoryProtocol {
        return self.repository
    }
    
    var authRepository: LegacyAuthRepositoryProtocol {
        return self.repository
    }
}
