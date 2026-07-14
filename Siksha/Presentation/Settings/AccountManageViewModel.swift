//
//  AccountManageViewModel.swift
//  Siksha
//
//  Created by Codex on 7/13/26.
//

import Combine
import Foundation

@MainActor
final class AccountManageViewModel: ObservableObject {
    @Published var error: AppError?
    @Published var showLogoutConfirmation = false
    @Published var showDeleteAccountConfirmation = false
    @Published var logoutFailed = false
    @Published var deleteAccountFailed = false
    @Published private(set) var isProcessing = false

    private let logoutUseCase: LogoutUseCase
    private let deleteAccountUseCase: DeleteAccountUseCase

    init(
        logoutUseCase: LogoutUseCase,
        deleteAccountUseCase: DeleteAccountUseCase
    ) {
        self.logoutUseCase = logoutUseCase
        self.deleteAccountUseCase = deleteAccountUseCase
    }

    func logout() async -> Bool {
        guard beginOperation() else { return false }
        defer { isProcessing = false }

        do {
            try await logoutUseCase.execute()
            return true
        } catch {
            self.error = ErrorHelper.categorize(error)
            logoutFailed = true
            return false
        }
    }

    func deleteAccount() async -> Bool {
        guard beginOperation() else { return false }
        defer { isProcessing = false }

        do {
            try await deleteAccountUseCase.execute()
            return true
        } catch let failure as DeleteAccountFailure {
            self.error = ErrorHelper.categorize(failure.accountDeletionError)
            deleteAccountFailed = true
            return false
        } catch {
            self.error = ErrorHelper.categorize(error)
            deleteAccountFailed = true
            return false
        }
    }

    private func beginOperation() -> Bool {
        guard !isProcessing else { return false }

        error = nil
        logoutFailed = false
        deleteAccountFailed = false
        isProcessing = true
        return true
    }
}
