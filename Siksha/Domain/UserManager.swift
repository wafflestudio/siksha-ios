//
//  UserManager.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/12/04.
//

import Foundation
import Combine
import Alamofire
import UIKit

class UserManager: ObservableObject {
    static let shared = UserManager()
    
    @Published var nickname: String?
    @Published var imageURL: String?
    @Published var imageData: Data?
    
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
                self?.imageURL = user.image
            })
            .store(in: &cancellables)
    }
    
    func updateUserProfile(nickname: String?, image: Data?, changeToDefaultImage: Bool, completion: @escaping (Bool, Error?) -> Void) {
        let nickname = self.nickname == nickname ? nil : nickname
        userRepository.updateUserProfile(nickname: nickname, image: image, changeToDefaultImage: changeToDefaultImage)
            .receive(on: DispatchQueue.main)
            .sink { completionStatus in
                switch completionStatus {
                case .finished:
                    completion(true, nil)
                case .failure(let error):
                    completion(false, error)
                }
            } receiveValue: { [weak self] user in
                self?.nickname = user.nickname
                self?.imageURL = user.image
                guard let imageURL = user.image else { return }
                self?.fetchImageData(from: imageURL) { [weak self] data in
                    self?.imageData = data
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchImage(from urlString: String) -> AnyPublisher<UIImage?, Never> {
        return Future<UIImage?, Never> { promise in
            AF.request(urlString).responseData { response in
                if let data = response.data, let image = UIImage(data: data) {
                    promise(.success(image))
                } else {
                    promise(.success(nil))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    private func fetchImageData(from urlString: String, completion: @escaping (Data?) -> Void) {
        AF.request(urlString).responseData { response in
            completion(response.data)
        }
    }

}
