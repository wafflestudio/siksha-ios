//
//  ManageRestaurantsWithoutMenuVisibilityUseCase.swift
//  Siksha
//
//  Created by Codex on 7/1/26.
//

protocol ManageRestaurantsWithoutMenuVisibilityUseCase {
    func shouldHideRestaurantsWithoutMenu() -> Bool
    func setShouldHideRestaurantsWithoutMenu(_ shouldHide: Bool)
}

final class DefaultManageRestaurantsWithoutMenuVisibilityUseCase: ManageRestaurantsWithoutMenuVisibilityUseCase {
    private let repository: UserPreferenceRepositoryProtocol

    init(repository: UserPreferenceRepositoryProtocol) {
        self.repository = repository
    }

    func shouldHideRestaurantsWithoutMenu() -> Bool {
        repository.shouldHideRestaurantsWithoutMenu()
    }

    func setShouldHideRestaurantsWithoutMenu(_ shouldHide: Bool) {
        repository.setShouldHideRestaurantsWithoutMenu(shouldHide)
    }
}
