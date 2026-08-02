//
//  CheckAppUpdateRequirementUseCase.swift
//  Siksha
//

enum AppUpdateRequirementResult: Equatable, Sendable {
    case updateRequired
    case updateNotRequired
    case unavailable
}

protocol CheckAppUpdateRequirementUseCase {
    func execute(currentVersion: String) async -> AppUpdateRequirementResult
}

final class DefaultCheckAppUpdateRequirementUseCase: CheckAppUpdateRequirementUseCase {
    private let repository: VersionPolicyRepositoryProtocol

    init(repository: VersionPolicyRepositoryProtocol) {
        self.repository = repository
    }

    func execute(currentVersion: String) async -> AppUpdateRequirementResult {
        guard let currentVersion = AppVersion(rawValue: currentVersion) else {
            return .unavailable
        }

        do {
            let minimumVersion = try await repository.fetchMinimumSupportedVersion()
            return currentVersion < minimumVersion ? .updateRequired : .updateNotRequired
        } catch {
            return .unavailable
        }
    }
}
