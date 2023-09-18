//
//  Repository.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/11.
//

import Combine

protocol NetworkModuleProtocol {
    func request<T: Decodable>(endpoint: SikshaAPI, params: [String: String]?) -> AnyPublisher<T, Error>
}

final class Repository: RepositoryProtocol {
    private let networkModule: NetworkModuleProtocol
    init(networkModule: NetworkModuleProtocol) {
        self.networkModule = networkModule
    }
}

extension Repository: CommunityRepositoryProtocol {
    func loadBoardList() {

    }
}


