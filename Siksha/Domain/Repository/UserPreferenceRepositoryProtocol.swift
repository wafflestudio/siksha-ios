//
//  UserPreferenceRepositoryProtocol.swift
//  Siksha
//
//  Created by Codex on 6/18/26.
//

import Foundation

protocol UserPreferenceRepositoryProtocol {
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
}
