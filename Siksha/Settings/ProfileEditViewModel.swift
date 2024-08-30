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
    var profileImage: UIImage? { get }
    var imageURL: String? { get }
    var addedImages: [UIImage] { get set }
    var enableDoneButton: Bool { get }
    var showNicknameExistsToast: Bool { get }
    var shouldDismiss: Bool { get }
    
    func loadInfo()
    func resetNickname()
    func setPreviousNickname()
    func updateUserProfile()
}

final class ProfileEditViewModel: ProfileEditViewModelType {
    private var cancellables = Set<AnyCancellable>()
    
    @Published var nickname: String = ""
    @Published var addedImages: [UIImage] = []
    @Published private(set) var imageURL: String?
    @Published private(set) var profileImage: UIImage?
    @Published private(set) var enableDoneButton: Bool = false
    @Published private(set) var showNicknameExistsToast: Bool = false
    @Published private(set) var shouldDismiss: Bool = false
    
    private var toastWorkItem: DispatchWorkItem?
    
    private var previousNickname: String?
    
    private var doneButtonEnabledPublisher: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest($nickname, $addedImages)
            .map { nickname, addedImages in
                return !nickname.isEmpty && (nickname != UserManager.shared.nickname || !addedImages.isEmpty )
            }
            .eraseToAnyPublisher()
    }
    
    private var profileImagePublisher: AnyPublisher<UIImage?, Never> {
        return Publishers.CombineLatest($addedImages.map { $0.first }, $imageURL)
            .flatMap { (addedImage, imageURLString) -> AnyPublisher<UIImage?, Never> in
                if let addedImage = addedImage {
                    return Just(addedImage).eraseToAnyPublisher()
                } else if let imageURLString = imageURLString, !imageURLString.isEmpty {
                    return UserManager.shared.fetchImage(from: imageURLString)
                } else {
                    return Just(nil).eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    init() {
        setupBindings()
    }
    
    func loadInfo() {
        UserManager.shared.loadUserInfo()
    }
    
    func resetNickname() {
        guard let previousNickname else { return }
        nickname = previousNickname
    }
    
    func setPreviousNickname() {
        previousNickname = nickname
    }
    
    func updateUserProfile() {
        let imageData = addedImages.first?.jpegData(compressionQuality: 0.8)
        UserManager.shared.updateUserProfile(nickname: nickname, image: imageData) {[weak self] success, error in
            if success {
                self?.shouldDismiss = true
            } else {
                print("업데이트 실패")
                if let networkError = error as? NetworkError {
                    switch networkError {
                    case .conflict:
                        self?.showToast()
                    default:
                        break
                    }
                }
            }
        }
    }
    
    private func showToast() {
        toastWorkItem?.cancel()
        showNicknameExistsToast = true
        
        let workItem = DispatchWorkItem { [weak self] in
            self?.showNicknameExistsToast = false
        }
        toastWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8, execute: workItem)
    }
    
    private func setupBindings() {
        doneButtonEnabledPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.enableDoneButton, on: self)
            .store(in: &cancellables)
        
        profileImagePublisher
           .receive(on: RunLoop.main)
           .assign(to: \.profileImage, on: self)
           .store(in: &cancellables)
        
        UserManager.shared.$nickname
            .receive(on: RunLoop.main)
            .sink { [weak self] nickname in
                self?.nickname = nickname ?? ""
                if self?.previousNickname == nil {
                    self?.previousNickname = nickname
                }
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
