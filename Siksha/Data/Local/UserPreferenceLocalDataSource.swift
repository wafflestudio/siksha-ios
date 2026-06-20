//
//  UserPreferenceLocalDataSource.swift
//  Siksha
//
//  Created by Codex on 6/18/26.
//

import Foundation

protocol UserPreferenceLocalDataSource {
    func menuFilters() -> MenuFilters
    func saveMenuFilters(_ filters: MenuFilters)

    func shouldHideRestaurantsWithoutMenu() -> Bool
    func setShouldHideRestaurantsWithoutMenu(_ isHidden: Bool)

    func isFestivalFeatureAvailable() -> Bool
    func setFestivalFeatureAvailable(_ isAvailable: Bool)

    func isFestivalSwitchOn() -> Bool
    func setFestivalSwitchOn(_ isOn: Bool)

    func isFestivalAppIconEnabled() -> Bool
    func setFestivalAppIconEnabled(_ isEnabled: Bool)

    func setCanSubmitReview(_ canSubmit: Bool)
}

final class UserDefaultsUserPreferenceLocalDataSource: UserPreferenceLocalDataSource {
    private enum Key {
        static let menuFilters = "menuFilters"
        static let shouldShowRestaurantsWithoutMenu = "notNoMenuHide"
        static let festivalFeatureAvailable = "isFestivalAvailable"
        static let festivalSwitchOn = "isFestival"
        static let festivalAppIconEnabled = "isFestivalAppIconEnabled"
        static let canSubmitReview = "canSubmitReview"
    }

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
    }

    func menuFilters() -> MenuFilters {
        guard let data = userDefaults.data(forKey: Key.menuFilters),
              let filters = try? decoder.decode(MenuFilters.self, from: data) else {
            return MenuFilters()
        }
        return filters
    }

    func saveMenuFilters(_ filters: MenuFilters) {
        guard let data = try? encoder.encode(filters) else {
            return
        }
        userDefaults.set(data, forKey: Key.menuFilters)
    }

    func shouldHideRestaurantsWithoutMenu() -> Bool {
        !userDefaults.bool(forKey: Key.shouldShowRestaurantsWithoutMenu)
    }

    func setShouldHideRestaurantsWithoutMenu(_ isHidden: Bool) {
        userDefaults.set(!isHidden, forKey: Key.shouldShowRestaurantsWithoutMenu)
    }

    func isFestivalFeatureAvailable() -> Bool {
        userDefaults.bool(forKey: Key.festivalFeatureAvailable)
    }

    func setFestivalFeatureAvailable(_ isAvailable: Bool) {
        userDefaults.set(isAvailable, forKey: Key.festivalFeatureAvailable)
    }

    func isFestivalSwitchOn() -> Bool {
        userDefaults.bool(forKey: Key.festivalSwitchOn)
    }

    func setFestivalSwitchOn(_ isOn: Bool) {
        userDefaults.set(isOn, forKey: Key.festivalSwitchOn)
    }

    func isFestivalAppIconEnabled() -> Bool {
        userDefaults.bool(forKey: Key.festivalAppIconEnabled)
    }

    func setFestivalAppIconEnabled(_ isEnabled: Bool) {
        userDefaults.set(isEnabled, forKey: Key.festivalAppIconEnabled)
    }

    func setCanSubmitReview(_ canSubmit: Bool) {
        userDefaults.set(canSubmit, forKey: Key.canSubmitReview)
    }
}
