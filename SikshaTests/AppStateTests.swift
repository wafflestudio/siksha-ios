//
//  AppStateTests.swift
//  SikshaTests
//
//  Created by Codex on 7/12/26.
//

import XCTest

@testable import Siksha

@MainActor
final class AppStateTests: XCTestCase {
    func testInitialStateIsResolvingAuth() {
        let appState = AppState(
            resolveInitialAuthStateUseCase: ResolveInitialAuthStateUseCaseStub(
                result: .requiresLogin
            )
        )

        XCTAssertEqual(appState.rootState, .resolvingAuth)
    }

    func testResolveInitialAuthStateMapsAuthenticatedResult() async {
        let session = AuthSession(
            accessToken: "access-token",
            expiresAt: nil
        )
        let useCase = ResolveInitialAuthStateUseCaseStub(
            result: .authenticated(session)
        )
        let appState = AppState(resolveInitialAuthStateUseCase: useCase)

        await appState.resolveInitialAuthState()

        XCTAssertEqual(appState.rootState, .authenticated)
        XCTAssertEqual(useCase.executionCount, 1)
    }

    func testResolveInitialAuthStateMapsRequiresLoginResult() async {
        let useCase = ResolveInitialAuthStateUseCaseStub(result: .requiresLogin)
        let appState = AppState(resolveInitialAuthStateUseCase: useCase)

        await appState.resolveInitialAuthState()

        XCTAssertEqual(appState.rootState, .requiresLogin)
    }

    func testResolveInitialAuthStateExecutesOnlyOnce() async {
        let useCase = ResolveInitialAuthStateUseCaseStub(result: .requiresLogin)
        let appState = AppState(resolveInitialAuthStateUseCase: useCase)

        await appState.resolveInitialAuthState()
        await appState.resolveInitialAuthState()

        XCTAssertEqual(useCase.executionCount, 1)
    }

    func testLoginAndLogoutUpdateRootState() {
        let appState = AppState(
            resolveInitialAuthStateUseCase: ResolveInitialAuthStateUseCaseStub(
                result: .requiresLogin
            )
        )

        appState.didLogin()
        XCTAssertEqual(appState.rootState, .authenticated)

        appState.didLogout()
        XCTAssertEqual(appState.rootState, .requiresLogin)
    }
}

private final class ResolveInitialAuthStateUseCaseStub: ResolveInitialAuthStateUseCase {
    private let result: AuthState
    private(set) var executionCount = 0

    init(result: AuthState) {
        self.result = result
    }

    func execute() async -> AuthState {
        executionCount += 1
        return result
    }
}
