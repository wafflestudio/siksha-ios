//
//  UserPreferenceUseCase.swift
//  Siksha
//
//  Created by Codex on 6/18/26.
//

import Foundation

protocol UserPreferenceUseCase {
    func menuFilters() -> MenuFilters
    func saveMenuFilters(_ filters: MenuFilters)

    func shouldHideRestaurantsWithoutMenu() -> Bool
    func setShouldHideRestaurantsWithoutMenu(_ isHidden: Bool)

    func isFestivalFeatureAvailable() -> Bool
    func setFestivalFeatureAvailable(_ isAvailable: Bool)

    func isFestivalEnabled() -> Bool
    func setFestivalEnabled(_ isEnabled: Bool)

    func isFestivalAppIconEnabled() -> Bool
    func setFestivalAppIconEnabled(_ isEnabled: Bool)

    func setCanSubmitReview(_ canSubmit: Bool)
}

final class DefaultUserPreferenceUseCase: UserPreferenceUseCase {
    private let repository: UserPreferenceRepositoryProtocol

    init(repository: UserPreferenceRepositoryProtocol) {
        self.repository = repository
    }

    func menuFilters() -> MenuFilters {
        repository.menuFilters()
    }

    func saveMenuFilters(_ filters: MenuFilters) {
        repository.saveMenuFilters(filters)
    }

    func shouldHideRestaurantsWithoutMenu() -> Bool {
        repository.shouldHideRestaurantsWithoutMenu()
    }

    func setShouldHideRestaurantsWithoutMenu(_ isHidden: Bool) {
        repository.setShouldHideRestaurantsWithoutMenu(isHidden)
    }

    func isFestivalFeatureAvailable() -> Bool {
        repository.isFestivalFeatureAvailable()
    }

    func setFestivalFeatureAvailable(_ isAvailable: Bool) {
        repository.setFestivalFeatureAvailable(isAvailable)
    }

    func isFestivalEnabled() -> Bool {
        repository.isFestivalEnabled()
    }

    func setFestivalEnabled(_ isEnabled: Bool) {
        repository.setFestivalEnabled(isEnabled)
    }

    func isFestivalAppIconEnabled() -> Bool {
        repository.isFestivalAppIconEnabled()
    }

    func setFestivalAppIconEnabled(_ isEnabled: Bool) {
        repository.setFestivalAppIconEnabled(isEnabled)
    }

    func setCanSubmitReview(_ canSubmit: Bool) {
        repository.setCanSubmitReview(canSubmit)
    }
}
