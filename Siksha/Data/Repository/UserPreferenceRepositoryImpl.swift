//
//  UserPreferenceRepositoryImpl.swift
//  Siksha
//
//  Created by Codex on 6/18/26.
//

import Foundation

final class UserPreferenceRepositoryImpl: UserPreferenceRepositoryProtocol {
    private let localDataSource: UserPreferenceLocalDataSource

    init(localDataSource: UserPreferenceLocalDataSource = UserDefaultsUserPreferenceLocalDataSource()) {
        self.localDataSource = localDataSource
    }

    func menuFilters() -> MenuFilters {
        localDataSource.menuFilters()
    }

    func saveMenuFilters(_ filters: MenuFilters) {
        localDataSource.saveMenuFilters(filters)
    }

    func shouldHideRestaurantsWithoutMenu() -> Bool {
        localDataSource.shouldHideRestaurantsWithoutMenu()
    }

    func setShouldHideRestaurantsWithoutMenu(_ isHidden: Bool) {
        localDataSource.setShouldHideRestaurantsWithoutMenu(isHidden)
    }

    func isFestivalFeatureAvailable() -> Bool {
        localDataSource.isFestivalFeatureAvailable()
    }

    func setFestivalFeatureAvailable(_ isAvailable: Bool) {
        localDataSource.setFestivalFeatureAvailable(isAvailable)
    }

    func isFestivalEnabled() -> Bool {
        localDataSource.isFestivalEnabled()
    }

    func setFestivalEnabled(_ isEnabled: Bool) {
        localDataSource.setFestivalEnabled(isEnabled)
    }

    func isFestivalAppIconEnabled() -> Bool {
        localDataSource.isFestivalAppIconEnabled()
    }

    func setFestivalAppIconEnabled(_ isEnabled: Bool) {
        localDataSource.setFestivalAppIconEnabled(isEnabled)
    }

    func setCanSubmitReview(_ canSubmit: Bool) {
        localDataSource.setCanSubmitReview(canSubmit)
    }
}
