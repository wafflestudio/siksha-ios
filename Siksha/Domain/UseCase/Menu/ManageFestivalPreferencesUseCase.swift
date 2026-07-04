//
//  ManageFestivalPreferencesUseCase.swift
//  Siksha
//
//  Created by Codex on 7/1/26.
//

protocol ManageFestivalPreferencesUseCase {
    func isFeatureAvailable() -> Bool
    func setFeatureAvailable(_ isAvailable: Bool)

    func isSwitchOn() -> Bool
    func setSwitchOn(_ isOn: Bool)

    func isAppIconEnabled() -> Bool
    func setAppIconEnabled(_ isEnabled: Bool)
}

final class DefaultManageFestivalPreferencesUseCase: ManageFestivalPreferencesUseCase {
    private let repository: UserPreferenceRepositoryProtocol

    init(repository: UserPreferenceRepositoryProtocol) {
        self.repository = repository
    }

    func isFeatureAvailable() -> Bool {
        repository.isFestivalFeatureAvailable()
    }

    func setFeatureAvailable(_ isAvailable: Bool) {
        repository.setFestivalFeatureAvailable(isAvailable)
    }

    func isSwitchOn() -> Bool {
        repository.isFestivalSwitchOn()
    }

    func setSwitchOn(_ isOn: Bool) {
        repository.setFestivalSwitchOn(isOn)
    }

    func isAppIconEnabled() -> Bool {
        repository.isFestivalAppIconEnabled()
    }

    func setAppIconEnabled(_ isEnabled: Bool) {
        repository.setFestivalAppIconEnabled(isEnabled)
    }
}
