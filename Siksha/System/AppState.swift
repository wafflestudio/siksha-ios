//
//  AppState.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/02.
//
import SwiftUI

enum AppRootState: Equatable {
    case resolvingAuth
    case authenticated
    case requiresLogin
}

@MainActor
public final class AppState: ObservableObject {
    @Published private(set) var rootState: AppRootState = .resolvingAuth

    private let resolveInitialAuthStateUseCase: ResolveInitialAuthStateUseCase
    private var didResolveInitialAuthState = false

    init(
        resolveInitialAuthStateUseCase: ResolveInitialAuthStateUseCase = AppContainer.shared.useCases
            .resolveInitialAuthStateUseCase
    ) {
        self.resolveInitialAuthStateUseCase = resolveInitialAuthStateUseCase
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

    func didLogin() {
        rootState = .authenticated
    }

    func didLogout() {
        rootState = .requiresLogin
    }
}
