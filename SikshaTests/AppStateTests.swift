//
//  AppStateTests.swift
//  SikshaTests
//

import XCTest

@testable import Siksha

@MainActor
final class AppStateTests: XCTestCase {
    func testInitialStateIsResolvingAuthenticationAndCheckingUpdate() {
        let appState = makeAppState(authResult: .requiresLogin)

        XCTAssertEqual(appState.rootState, .resolvingAuth)
        XCTAssertEqual(appState.updateState, .checking)
    }

    func testPrepareForLaunchChecksVersionWhenAuthenticated() async {
        let updateUseCase = CheckAppUpdateRequirementUseCaseStub(results: [.updateRequired])
        let appState = makeAppState(
            authResult: .authenticated(AuthSession(accessToken: "token", expiresAt: nil)),
            updateUseCase: updateUseCase
        )

        await appState.prepareForLaunch()

        XCTAssertEqual(appState.rootState, .authenticated)
        XCTAssertEqual(appState.updateState, .required)
        XCTAssertEqual(updateUseCase.receivedVersions, ["3.5.0"])
    }

    func testPrepareForLaunchChecksVersionWhenLoginIsRequired() async {
        let updateUseCase = CheckAppUpdateRequirementUseCaseStub(results: [.updateRequired])
        let appState = makeAppState(authResult: .requiresLogin, updateUseCase: updateUseCase)

        await appState.prepareForLaunch()

        XCTAssertEqual(appState.rootState, .requiresLogin)
        XCTAssertEqual(appState.updateState, .required)
        XCTAssertEqual(updateUseCase.receivedVersions, ["3.5.0"])
    }

    func testLoginPreservesUpdateDecisionWithoutRechecking() async {
        let updateUseCase = CheckAppUpdateRequirementUseCaseStub(results: [.updateNotRequired])
        let appState = makeAppState(authResult: .requiresLogin, updateUseCase: updateUseCase)
        await appState.checkAppUpdateRequirement()

        appState.didLogin()

        XCTAssertEqual(appState.rootState, .authenticated)
        XCTAssertEqual(appState.updateState, .allowed)
        XCTAssertEqual(updateUseCase.receivedVersions, ["3.5.0"])
    }

    func testForegroundCheckRunsWhileLoginIsRequired() async {
        let updateUseCase = CheckAppUpdateRequirementUseCaseStub(results: [.updateRequired])
        let appState = makeAppState(authResult: .requiresLogin, updateUseCase: updateUseCase)
        await appState.resolveInitialAuthState()

        await appState.checkAppUpdateRequirement()

        XCTAssertEqual(appState.rootState, .requiresLogin)
        XCTAssertEqual(appState.updateState, .required)
        XCTAssertEqual(updateUseCase.receivedVersions, ["3.5.0"])
    }

    func testUnavailableInitialCheckAllowsAuthenticatedContent() async {
        let appState = makeAppState(
            authResult: .authenticated(AuthSession(accessToken: "token", expiresAt: nil)),
            updateUseCase: CheckAppUpdateRequirementUseCaseStub(results: [.unavailable])
        )

        await appState.prepareForLaunch()

        XCTAssertEqual(appState.updateState, .allowed)
    }

    func testUnavailableRecheckKeepsKnownUpdateRequirement() async {
        let updateUseCase = CheckAppUpdateRequirementUseCaseStub(
            results: [.updateRequired, .unavailable]
        )
        let appState = makeAppState(
            authResult: .authenticated(AuthSession(accessToken: "token", expiresAt: nil)),
            updateUseCase: updateUseCase
        )
        await appState.prepareForLaunch()

        await appState.checkAppUpdateRequirement()

        XCTAssertEqual(appState.updateState, .required)
        XCTAssertEqual(updateUseCase.receivedVersions.count, 2)
    }

    func testConcurrentUpdateChecksDoNotStartOverlappingRequests() async {
        let updateUseCase = ControlledCheckAppUpdateRequirementUseCase()
        let appState = AppState(
            resolveInitialAuthStateUseCase: ResolveInitialAuthStateUseCaseStub(
                result: .authenticated(AuthSession(accessToken: "token", expiresAt: nil))
            ),
            checkAppUpdateRequirementUseCase: updateUseCase,
            currentVersion: "3.5.0"
        )
        await appState.resolveInitialAuthState()

        let firstCheck = Task { await appState.checkAppUpdateRequirement() }
        await updateUseCase.waitUntilStarted()
        let secondCheck = Task { await appState.checkAppUpdateRequirement() }
        await secondCheck.value

        let executionCount = await updateUseCase.executionCount
        XCTAssertEqual(executionCount, 1)

        await updateUseCase.complete(with: .updateNotRequired)
        await firstCheck.value
    }

    func testResolveInitialAuthStateExecutesOnlyOnce() async {
        let authUseCase = ResolveInitialAuthStateUseCaseStub(result: .requiresLogin)
        let appState = AppState(
            resolveInitialAuthStateUseCase: authUseCase,
            checkAppUpdateRequirementUseCase: CheckAppUpdateRequirementUseCaseStub(
                results: [.updateNotRequired]
            ),
            currentVersion: "3.5.0"
        )

        await appState.resolveInitialAuthState()
        await appState.resolveInitialAuthState()

        XCTAssertEqual(authUseCase.executionCount, 1)
    }

    func testLogoutPreservesUpdateDecision() async {
        let appState = makeAppState(
            authResult: .requiresLogin,
            updateUseCase: CheckAppUpdateRequirementUseCaseStub(results: [.updateNotRequired])
        )
        await appState.checkAppUpdateRequirement()
        appState.didLogin()

        appState.didLogout()

        XCTAssertEqual(appState.rootState, .requiresLogin)
        XCTAssertEqual(appState.updateState, .allowed)
    }

    private func makeAppState(
        authResult: AuthState,
        updateUseCase: CheckAppUpdateRequirementUseCaseStub = CheckAppUpdateRequirementUseCaseStub(
            results: [.updateNotRequired]
        )
    ) -> AppState {
        AppState(
            resolveInitialAuthStateUseCase: ResolveInitialAuthStateUseCaseStub(result: authResult),
            checkAppUpdateRequirementUseCase: updateUseCase,
            currentVersion: "3.5.0"
        )
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

private final class CheckAppUpdateRequirementUseCaseStub: CheckAppUpdateRequirementUseCase {
    private var results: [AppUpdateRequirementResult]
    private(set) var receivedVersions: [String] = []

    init(results: [AppUpdateRequirementResult]) {
        self.results = results
    }

    func execute(currentVersion: String) async -> AppUpdateRequirementResult {
        receivedVersions.append(currentVersion)
        return results.removeFirst()
    }
}

private actor ControlledCheckAppUpdateRequirementUseCase: CheckAppUpdateRequirementUseCase {
    private(set) var executionCount = 0
    private var continuation: CheckedContinuation<AppUpdateRequirementResult, Never>?

    func execute(currentVersion: String) async -> AppUpdateRequirementResult {
        executionCount += 1
        return await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func waitUntilStarted() async {
        while executionCount == 0 {
            await Task.yield()
        }
    }

    func complete(with result: AppUpdateRequirementResult) {
        continuation?.resume(returning: result)
        continuation = nil
    }
}
