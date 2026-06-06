//
//  FetchDailyMenuUseCase.swift
//  Siksha
//
//  Created by Codex on 6/7/26.
//

enum FetchDailyMenuResult {
    case succeeded(DailyMenuModel)
    case empty
    case cached(DailyMenuModel)
    case failed
}

protocol FetchDailyMenuUseCase {
    @MainActor
    func execute(date: String) async -> FetchDailyMenuResult
}

final class DefaultFetchDailyMenuUseCase: FetchDailyMenuUseCase {
    private let repository: MenuRepositoryProtocol
    
    init(repository: MenuRepositoryProtocol) {
        self.repository = repository
    }
    
    @MainActor
    func execute(date: String) async -> FetchDailyMenuResult {
        do {
            let hasRemoteMenu = try await repository.refreshMenu(date: date)
            guard hasRemoteMenu else {
                return .empty
            }
            
            if let menu = repository.getMenu(date: date) {
                return .succeeded(menu)
            }
        } catch {
            if let cachedMenu = repository.getMenu(date: date) {
                return .cached(cachedMenu)
            }
        }
        
        return .failed
    }
}
