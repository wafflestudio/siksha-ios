//
//  AppRootView.swift
//  Siksha
//
//  Created by Codex on 7/12/26.
//

import SwiftUI

struct AppRootView: View {
    @StateObject private var appState: AppState
    private let imageCache: ImageCache

    init(appState: AppState, imageCache: ImageCache) {
        _appState = StateObject(wrappedValue: appState)
        self.imageCache = imageCache
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
        .environment(\.imageCache, imageCache)
        .task {
            await appState.resolveInitialAuthState()
        }
    }
}
