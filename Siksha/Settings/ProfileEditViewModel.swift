//
//  ProfileEditViewModel.swift
//  Siksha
//
//  Created by 이지현 on 5/12/24.
//

import SwiftUI
import Combine

protocol ProfileEditViewModelType: ObservableObject {
    var nickname: String { get set }
    var imageURL: String? { get }
    var addedImages: [UIImage] { get set }
    var enableDoneButton: Bool { get }
    
    func loadInfo()
    func updateUserProfile()
}

final class ProfileEditViewModel: ProfileEditViewModelType {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var nickname: String = ""
    @Published var addedImages: [UIImage] = []
    @Published private(set) var imageURL: String?
    @Published private(set) var enableDoneButton: Bool = false
    
    private var doneButtonEnabledPublisher: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest($nickname, $addedImages)
            .map { nickname, addedImages in
                return !nickname.isEmpty && (nickname != UserManager.shared.nickname || !addedImages.isEmpty )
            }
            .eraseToAnyPublisher()
    }
    
    init() {
        setupBindings()
    }
    
    func loadInfo() {
        UserManager.shared.loadUserInfo()
    }
    
    func updateUserProfile() {
        let imageData = addedImages.first?.jpegData(compressionQuality: 0.8)
        UserManager.shared.updateUserProfile(nickname: nickname, image: imageData) { success in
            if success {
                print("업데이트 성공")
            } else {
                print("업데이트 실패")
            }
            
        }
    }
    
    private func setupBindings() {
        doneButtonEnabledPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.enableDoneButton, on: self)
            .store(in: &cancellables)
        
        UserManager.shared.$nickname
            .receive(on: RunLoop.main)
            .sink { [weak self] nickname in
                self?.nickname = nickname ?? ""
            }
            .store(in: &cancellables)
        
        UserManager.shared.$imageURL
            .receive(on: RunLoop.main)
            .sink { [weak self] imageURL in
                self?.imageURL = imageURL
            }
            .store(in: &cancellables)
    }
}
