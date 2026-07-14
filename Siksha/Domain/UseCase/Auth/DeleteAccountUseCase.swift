//
//  DeleteAccountUseCase.swift
//  Siksha
//
//  Created by Codex on 7/13/26.
//

protocol DeleteAccountUseCase {
    func execute() async throws
}

struct DeleteAccountFailure: Error {
    let accountDeletionError: Error
    let deviceRestorationError: Error?
}

final class DefaultDeleteAccountUseCase: DeleteAccountUseCase {
    private let deviceTokenLifecycle: DeviceTokenLifecycle
    private let userRepository: UserRepositoryProtocol
    private let accountLocalStateCleaner: AccountLocalStateCleaner

    init(
        deviceTokenLifecycle: DeviceTokenLifecycle,
        userRepository: UserRepositoryProtocol,
        accountLocalStateCleaner: AccountLocalStateCleaner
    ) {
        self.deviceTokenLifecycle = deviceTokenLifecycle
        self.userRepository = userRepository
        self.accountLocalStateCleaner = accountLocalStateCleaner
    }

    func execute() async throws {
        do {
            try await deviceTokenLifecycle.performWithCurrentDeviceUnregistered {
                try await self.userRepository.deleteAccount()
                await self.accountLocalStateCleaner.execute()
            }
        } catch let failure as DeviceTokenLifecycleOperationFailure {
            throw DeleteAccountFailure(
                accountDeletionError: failure.operationError,
                deviceRestorationError: failure.deviceRestorationError
            )
        }
    }
}
