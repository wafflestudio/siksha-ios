//
//  AppState.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/02.
//
import Foundation
import SwiftUI

enum AppRootState: Equatable {
    case resolvingAuth
    case authenticated
    case requiresLogin
}

enum AppUpdateState: Equatable {
    case checking
    case allowed
    case required
}

@MainActor
public final class AppState: ObservableObject {
    @Published private(set) var rootState: AppRootState = .resolvingAuth
    @Published private(set) var updateState: AppUpdateState = .checking

    private let resolveInitialAuthStateUseCase: ResolveInitialAuthStateUseCase
    private let checkAppUpdateRequirementUseCase: CheckAppUpdateRequirementUseCase
    private let currentVersion: String
    private var didResolveInitialAuthState = false
    private var didPrepareForLaunch = false
    private var isCheckingAppUpdate = false

    init(
        resolveInitialAuthStateUseCase: ResolveInitialAuthStateUseCase = AppContainer.shared.useCases
            .resolveInitialAuthStateUseCase,
        checkAppUpdateRequirementUseCase: CheckAppUpdateRequirementUseCase = AppContainer.shared.useCases
            .checkAppUpdateRequirementUseCase,
        currentVersion: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
    ) {
        self.resolveInitialAuthStateUseCase = resolveInitialAuthStateUseCase
        self.checkAppUpdateRequirementUseCase = checkAppUpdateRequirementUseCase
        self.currentVersion = currentVersion
    }

    func prepareForLaunch() async {
        guard !didPrepareForLaunch else {
            return
        }

        didPrepareForLaunch = true
        await resolveInitialAuthState()

        guard rootState == .authenticated else {
            return
        }

        await checkAppUpdateRequirement()
    }

    func resolveInitialAuthState() async {
        guard !didResolveInitialAuthState else {
            return
        }

        didResolveInitialAuthState = true

        switch await resolveInitialAuthStateUseCase.execute() {
        case .authenticated:
            rootState = .authenticated
        case .requiresLogin:
            rootState = .requiresLogin
        }
    }

    func didLogin() async {
        updateState = .checking
        rootState = .authenticated
        await checkAppUpdateRequirement()
    }

    func didLogout() {
        updateState = .checking
        rootState = .requiresLogin
    }

    func checkAppUpdateRequirement() async {
        guard rootState == .authenticated, !isCheckingAppUpdate else {
            return
        }

        let previousState = updateState
        isCheckingAppUpdate = true
        if previousState == .required {
            updateState = .checking
        }
        defer { isCheckingAppUpdate = false }

        switch await checkAppUpdateRequirementUseCase.execute(currentVersion: currentVersion) {
        case .updateRequired:
            updateState = .required
        case .updateNotRequired:
            updateState = .allowed
        case .unavailable:
            updateState = previousState == .required ? .required : .allowed
        }
    }
}
