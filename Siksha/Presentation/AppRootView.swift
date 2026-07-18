//
//  AppRootView.swift
//  Siksha
//
//  Created by Codex on 7/12/26.
//

import SwiftUI

struct AppRootView:View {
    @StateObject private var appState: AppState

    init(appState: AppState) {
        _appState = StateObject(wrappedValue: appState)
    }

    var body: some View {
        Group {
            switch appState.rootState {
            case .resolvingAuth:
                StartupView()
            case .authenticated:
                ContentView()
            case .requiresLogin:
                LoginView()
            }
        }
        .environmentObject(appState)
        .task {
            await appState.resolveInitialAuthState()
        }
    }
}
