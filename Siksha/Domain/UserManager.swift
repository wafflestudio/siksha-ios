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
    
    @Published var nickname: String?
    @Published var image: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let userRepository: UserRepositoryProtocol
    
    private init(userRepository: UserRepositoryProtocol = DomainManager.shared.domain.userRepository) {
        self.userRepository = userRepository
    }

    func loadUserInfo() {
        userRepository.loadUserInfo()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print(error)
                }
            }, receiveValue: { [weak self] user in
                self?.nickname = user.nickname
                self?.image = user.image
            })
            .store(in: &cancellables)
    }
    
    func updateUserProfile(nickname: String?, image: Data?, completion: @escaping (Bool) -> Void) {
        userRepository.updateUserProfile(nickname: nickname, image: image)
            .receive(on: DispatchQueue.main)
            .sink { completionStatus in
                switch completionStatus {
                case .finished:
                    completion(true)
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            } receiveValue: { [weak self] user in
                self?.nickname = user.nickname
                self?.image = user.image
            }
            .store(in: &cancellables)
        
    }

}
