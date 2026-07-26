//
//  AppRootView.swift
//  Siksha
//
//  Created by Codex on 7/12/26.
//

import SwiftUI

struct AppRootView: View {
    @StateObject private var appState: AppState
    @StateObject private var contentViewModel: ContentViewModel
    private let imageCache: ImageCache

    init(
        appState: AppState,
        imageCache: ImageCache,
        contentViewModel: ContentViewModel = ContentViewModel()
    ) {
        _appState = StateObject(wrappedValue: appState)
        _contentViewModel = StateObject(wrappedValue: contentViewModel)
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
        .environmentObject(contentViewModel)
        .environment(\.imageCache, imageCache)
        .task {
            await appState.resolveInitialAuthState()
        }
    }
}
