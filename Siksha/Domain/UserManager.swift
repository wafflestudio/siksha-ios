//
//  UserManager.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/12/04.
//

import Foundation
import Combine

class UserManager: ObservableObject {
    static let shared = UserManager()
    @Published var userId: Int?
    private var cancellables = Set<AnyCancellable>()

    func loadUserInfo() {
        DomainManager.shared.domain.userRepository.loadUserInfo()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { error in
                print(error)
            }, receiveValue: { [weak self] user in
                self?.userId = user.id
            })
            .store(in: &cancellables)
    }
}
