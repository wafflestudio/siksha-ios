//
//  ManageMenuFiltersUseCase.swift
//  Siksha
//
//  Created by Codex on 7/1/26.
//

protocol ManageMenuFiltersUseCase {
    func loadFilters() -> MenuFilters
    func saveFilters(_ filters: MenuFilters)
}

final class DefaultManageMenuFiltersUseCase: ManageMenuFiltersUseCase {
    private let repository: UserPreferenceRepositoryProtocol

    init(repository: UserPreferenceRepositoryProtocol) {
        self.repository = repository
    }

    func loadFilters() -> MenuFilters {
        repository.menuFilters()
    }

    func saveFilters(_ filters: MenuFilters) {
        repository.saveMenuFilters(filters)
    }
}
