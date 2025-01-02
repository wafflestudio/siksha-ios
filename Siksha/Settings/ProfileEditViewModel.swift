//
//  ProfileEditViewModel.swift
//  Siksha
//
//  Created by 이지현 on 5/12/24.
//

import Foundation
import Combine

protocol ProfileEditViewModelType: ObservableObject {
    var error: AppError? { get set }
    var nickname: String { get set }
    var profileImageData: Data? { get set }
    var enableDoneButton: Bool { get }
    var showNicknameExistsToast: Bool { get }
    var shouldDismiss: Bool { get }
    
    func loadInfo()
    func resetNickname()
    func setPreviousNickname()
    func updateUserProfile()
    func setProfileImage(with imageData: Data?)
}

final class ProfileEditViewModel: ProfileEditViewModelType {
    
    private var cancellables = Set<AnyCancellable>()
    
    @Published var error: AppError?
    @Published var nickname = ""
    @Published var profileImageData: Data?
    @Published private(set) var enableDoneButton = false
    @Published private(set) var showNicknameExistsToast = false
    @Published private(set) var shouldDismiss = false
    @Published private var isProfileImageChanged = false
    
    private var toastWorkItem: DispatchWorkItem?
    private var previousNickname: String?
    
    private var doneButtonEnabledPublisher: AnyPublisher<Bool, Never> {
        return Publishers.CombineLatest($nickname, $isProfileImageChanged)
            .map { nickname, isProfileImageChanged in
                return !nickname.isEmpty && (nickname != UserManager.shared.nickname || isProfileImageChanged )
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
    
    func setProfileImage(with imageData: Data?) {
        self.profileImageData = imageData
        self.isProfileImageChanged = true
    }
    
    func updateUserProfile() {
        UserManager.shared.updateUserProfile(nickname: nickname, image: profileImageData, changeToDefaultImage: profileImageData == nil) {[weak self] success, error in
            if success {
                self?.shouldDismiss = true
            } else {
                self?.error = AppError.unknownError("업데이트 실패")
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
        
        UserManager.shared.$nickname
            .receive(on: RunLoop.main)
            .sink { [weak self] nickname in
                self?.nickname = nickname ?? ""
                if self?.previousNickname == nil {
                    self?.previousNickname = nickname
                }
            }
            .store(in: &cancellables)
        
        UserManager.shared.$imageData
            .receive(on: RunLoop.main)
            .sink { [weak self] data in
                self?.profileImageData = data
            }
            .store(in: &cancellables)
    }
}
