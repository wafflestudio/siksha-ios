//
//  ProfileEditViewModel.swift
//  Siksha
//
//  Created by 이지현 on 5/12/24.
//

import Foundation

protocol ProfileEditViewModelType: ObservableObject {
    var nickname: String { get set }
}

final class ProfileEditViewModel: ProfileEditViewModelType {
    @Published var nickname = "닉네임"
}
