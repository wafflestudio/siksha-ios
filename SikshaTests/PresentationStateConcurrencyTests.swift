//
//  PresentationStateConcurrencyTests.swift
//  SikshaTests
//

import Combine
import UIKit
import XCTest

@testable import Siksha

@MainActor
final class PresentationStateConcurrencyTests: XCTestCase {
    func testLatestSelectedDateWinsWhenOlderMenuRequestFinishesLast() async {
        let fetchDailyMenu = ControlledFetchDailyMenuUseCase()
        let viewModel = makeMenuViewModel(fetchDailyMenu: fetchDailyMenu)
        let initialDate = viewModel.selectedDate

        await waitUntil { fetchDailyMenu.requestedDates == [initialDate] }
        viewModel.selectedDate = "2099-01-01"
        await waitUntil { fetchDailyMenu.requestedDates == [initialDate, "2099-01-01"] }

        fetchDailyMenu.complete(date: "2099-01-01", with: .empty)
        await waitUntil {
            if case .idle = viewModel.getMenuStatus {
                return true
            }
            return false
        }

        fetchDailyMenu.complete(date: initialDate, with: .failed)
        await Task.yield()

        XCTAssertFalse(viewModel.showNetworkAlert)
        guard case .idle = viewModel.getMenuStatus else {
            return XCTFail("Expected the latest menu request to remain authoritative")
        }
    }

    func testLatestAlarmTimeFetchWinsWhenOlderRequestFinishesLast() async {
        let fetchAlarmTime = ControlledFetchMenuAlarmTimeUseCase()
        let viewModel = makeMyLikedMenuViewModel(fetchAlarmTime: fetchAlarmTime)

        viewModel.getAlarmTime()
        await waitUntil { fetchAlarmTime.executionCount == 1 }
        viewModel.getAlarmTime()
        await waitUntil { fetchAlarmTime.executionCount == 2 }

        fetchAlarmTime.completeRequest(at: 1, with: .EVERY_MEAL)
        await waitUntil { viewModel.alarmTime == .EVERY_MEAL }
        fetchAlarmTime.completeRequest(at: 0, with: .DAILY)
        await Task.yield()

        XCTAssertEqual(viewModel.alarmTime, .EVERY_MEAL)
    }

    func testKeyboardHideCancelsDelayedDidShowUpdate() async {
        let responder = KeyboardResponder(showDelayNanoseconds: 1_000_000)
        let frame = CGRect(x: 0, y: 0, width: 300, height: 250)

        NotificationCenter.default.post(
            name: UIResponder.keyboardWillShowNotification,
            object: nil,
            userInfo: [UIResponder.keyboardFrameEndUserInfoKey: frame]
        )
        await waitUntil { responder.currentHeight == 250 }

        NotificationCenter.default.post(name: UIResponder.keyboardDidShowNotification, object: nil)
        NotificationCenter.default.post(name: UIResponder.keyboardWillHideNotification, object: nil)
        try? await Task.sleep(nanoseconds: 5_000_000)

        XCTAssertFalse(responder.didKeyboardShow)
        XCTAssertEqual(responder.currentHeight, 0)
    }

    func testPopupCancellationPreventsDelayedOpacityMutation() async throws {
        let (userDefaults, suiteName) = try makeUserDefaults()
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        let state = ContentViewModel(
            userDefaults: userDefaults,
            popupDismissDelayNanoseconds: 1_000_000
        )

        state.schedulePopupDismissalIfNeeded()
        XCTAssertEqual(state.popUpOpacity, 1)
        state.cancelPopupDismissal()

        XCTAssertEqual(state.popUpOpacity, 0)
        try await Task.sleep(nanoseconds: 5_000_000)
        XCTAssertEqual(state.popUpOpacity, 0)
        XCTAssertEqual(userDefaults.integer(forKey: "alarmPopupCount"), 1)
    }

    func testPopupDismissalTaskDoesNotRetainContentState() async throws {
        let (userDefaults, suiteName) = try makeUserDefaults()
        defer { userDefaults.removePersistentDomain(forName: suiteName) }
        var state: ContentViewModel? = ContentViewModel(
            userDefaults: userDefaults,
            popupDismissDelayNanoseconds: 1_000_000_000
        )
        let weakState = WeakReference(state)

        state?.schedulePopupDismissalIfNeeded()
        await Task.yield()
        state = nil

        XCTAssertNil(weakState.value)
    }

    func testCancelledAlarmEnableRequestDoesNotAffectReplacement() async {
        let updateAllAlarms = ControlledUpdateAllMenuAlarmsUseCase()
        let viewModel = makeMyLikedMenuViewModel(
            fetchAlarmTime: ControlledFetchMenuAlarmTimeUseCase(),
            updateAllAlarms: updateAllAlarms
        )

        viewModel.requestAlarmEnabledChange(true)
        await waitUntil { updateAllAlarms.executionCount == 1 }
        viewModel.setAlarmEnabled(false)
        viewModel.requestAlarmEnabledChange(true)
        await waitUntil { updateAllAlarms.executionCount == 2 }

        updateAllAlarms.completeRequest(at: 0)
        try? await Task.sleep(nanoseconds: 1_000_000)
        XCTAssertTrue(viewModel.isUpdatingAlarmEnabled)

        updateAllAlarms.completeRequest(at: 1)
        await waitUntil { !viewModel.isUpdatingAlarmEnabled }

        XCTAssertNil(viewModel.error)
        XCTAssertTrue(viewModel.isAlarmEnabled)
    }

    func testIndependentAppRootsDoNotShareContentState() throws {
        let (firstDefaults, firstSuiteName) = try makeUserDefaults()
        let (secondDefaults, secondSuiteName) = try makeUserDefaults()
        defer {
            firstDefaults.removePersistentDomain(forName: firstSuiteName)
            secondDefaults.removePersistentDomain(forName: secondSuiteName)
        }
        let firstState = ContentViewModel(userDefaults: firstDefaults)
        let secondState = ContentViewModel(userDefaults: secondDefaults)

        _ = AppRootView(
            appState: AppState(
                resolveInitialAuthStateUseCase: ResolveInitialAuthStateUseCaseStub(),
                checkAppUpdateRequirementUseCase: CheckAppUpdateRequirementUseCaseStub()
            ),
            imageCache: TemporaryImageCache(),
            contentViewModel: firstState
        )
        _ = AppRootView(
            appState: AppState(
                resolveInitialAuthStateUseCase: ResolveInitialAuthStateUseCaseStub(),
                checkAppUpdateRequirementUseCase: CheckAppUpdateRequirementUseCaseStub()
            ),
            imageCache: TemporaryImageCache(),
            contentViewModel: secondState
        )

        firstState.showModal = false
        firstState.showPopUp = true

        XCTAssertTrue(secondState.showModal)
        XCTAssertFalse(secondState.showPopUp)
    }

    private func makeMenuViewModel(fetchDailyMenu: FetchDailyMenuUseCase) -> MenuViewModel {
        MenuViewModel(
            analytics: AnalyticsServiceStub(),
            fetchDailyMenuUseCase: fetchDailyMenu,
            fetchFestivalDatesUseCase: FetchFestivalDatesUseCaseStub(),
            fetchRemoteConfigUseCase: FetchRemoteConfigUseCaseStub(),
            observeRemoteConfigUseCase: ObserveRemoteConfigUseCaseStub(),
            fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCaseStub(),
            updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCaseStub(),
            manageMenuFiltersUseCase: ManageMenuFiltersUseCaseStub(),
            manageRestaurantsWithoutMenuVisibilityUseCase: ManageRestaurantsWithoutMenuVisibilityUseCaseStub(),
            manageFestivalPreferencesUseCase: ManageFestivalPreferencesUseCaseStub(),
            checkFestivalSwitchVisibilityUseCase: CheckFestivalSwitchVisibilityUseCaseStub(),
            mealSectionRenderScheduler: MealSectionRenderSchedulerStub()
        )
    }

    private func makeMyLikedMenuViewModel(
        fetchAlarmTime: FetchMenuAlarmTimeUseCase,
        updateAllAlarms: UpdateAllMenuAlarmsUseCase = UpdateAllMenuAlarmsUseCaseStub()
    ) -> MyLikedMenuViewModel {
        MyLikedMenuViewModel(
            fetchMyLikedMenusUseCase: FetchMyLikedMenusUseCaseStub(),
            getMenuAlarmEnabledUseCase: GetMenuAlarmEnabledUseCaseStub(),
            setMenuAlarmEnabledUseCase: SetMenuAlarmEnabledUseCaseStub(),
            updateMenuAlarmUseCase: UpdateMenuAlarmUseCaseStub(),
            updateAllMenuAlarmsUseCase: updateAllAlarms,
            fetchMenuAlarmTimeUseCase: fetchAlarmTime,
            updateMenuAlarmTimeUseCase: UpdateMenuAlarmTimeUseCaseStub(),
            updateMenuLikeUseCase: UpdateMenuLikeUseCaseStub(),
            menuAlarmNotificationManager: MenuAlarmNotificationManagerStub(),
            fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCaseStub(),
            updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCaseStub()
        )
    }

    private func makeUserDefaults() throws -> (UserDefaults, String) {
        let suiteName = "PresentationStateConcurrencyTests.\(UUID().uuidString)"
        let userDefaults = try XCTUnwrap(UserDefaults(suiteName: suiteName))
        userDefaults.removePersistentDomain(forName: suiteName)
        return (userDefaults, suiteName)
    }

    private func waitUntil(
        _ condition: () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<1_000 {
            if condition() {
                return
            }
            await Task.yield()
        }
        XCTFail("Condition was not satisfied", file: file, line: line)
    }
}

@MainActor
private final class ControlledFetchDailyMenuUseCase: FetchDailyMenuUseCase {
    private var continuations: [String: CheckedContinuation<FetchDailyMenuResult, Never>] = [:]
    private(set) var requestedDates: [String] = []

    func execute(date: String) async -> FetchDailyMenuResult {
        requestedDates.append(date)
        return await withCheckedContinuation { continuation in
            continuations[date] = continuation
        }
    }

    func complete(date: String, with result: FetchDailyMenuResult) {
        continuations.removeValue(forKey: date)?.resume(returning: result)
    }
}

private final class ControlledFetchMenuAlarmTimeUseCase: FetchMenuAlarmTimeUseCase {
    private var continuations: [CheckedContinuation<AlarmTime, Never>?] = []

    var executionCount: Int { continuations.count }

    func execute() async throws -> AlarmTime {
        await withCheckedContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func completeRequest(at index: Int, with alarmTime: AlarmTime) {
        continuations[index]?.resume(returning: alarmTime)
        continuations[index] = nil
    }
}

private struct AnalyticsServiceStub: AnalyticsService {
    func track(_ event: AnalyticsEvent) {}
}

private struct FetchFestivalDatesUseCaseStub: FetchFestivalDatesUseCase {
    func execute() async throws -> [Date] { [] }
}

private struct FetchRemoteConfigUseCaseStub: FetchRemoteConfigUseCase {
    func execute() async throws -> RemoteConfigModel {
        RemoteConfigModel(festivalFeatureEnabled: false, festivalAppIconEnabled: false)
    }
}

private struct ObserveRemoteConfigUseCaseStub: ObserveRemoteConfigUseCase {
    func execute() -> AsyncStream<RemoteConfigModel> {
        AsyncStream { continuation in
            continuation.finish()
        }
    }
}

private struct FetchPersonalRestaurantsUseCaseStub: FetchPersonalRestaurantsUseCase {
    func execute() async throws -> [PersonalRestaurantModel] { [] }
}

private struct UpdateRestaurantPreferenceUseCaseStub: UpdateRestaurantPreferenceUseCase {
    func setLiked(
        restaurant: PersonalRestaurantModel,
        liked: Bool
    ) async throws -> RestaurantPreferenceStatusModel {
        RestaurantPreferenceStatusModel(id: restaurant.id, liked: liked, visible: restaurant.visible)
    }

    func setVisible(
        restaurant: PersonalRestaurantModel,
        visible: Bool
    ) async throws -> RestaurantPreferenceStatusModel {
        RestaurantPreferenceStatusModel(id: restaurant.id, liked: restaurant.liked, visible: visible)
    }
}

private struct ManageMenuFiltersUseCaseStub: ManageMenuFiltersUseCase {
    func loadFilters() -> MenuFilters { MenuFilters() }
    func saveFilters(_ filters: MenuFilters) {}
}

private struct ManageRestaurantsWithoutMenuVisibilityUseCaseStub:
    ManageRestaurantsWithoutMenuVisibilityUseCase
{
    func shouldHideRestaurantsWithoutMenu() -> Bool { false }
    func setShouldHideRestaurantsWithoutMenu(_ shouldHide: Bool) {}
}

private final class ManageFestivalPreferencesUseCaseStub: ManageFestivalPreferencesUseCase {
    func isFeatureAvailable() -> Bool { false }
    func setFeatureAvailable(_ isAvailable: Bool) {}
    func isSwitchOn() -> Bool { false }
    func setSwitchOn(_ isOn: Bool) {}
    func isAppIconEnabled() -> Bool { false }
    func setAppIconEnabled(_ isEnabled: Bool) {}
}

private struct CheckFestivalSwitchVisibilityUseCaseStub: CheckFestivalSwitchVisibilityUseCase {
    func execute(
        selectedDate: Date,
        festivalDates: [Date],
        isFeatureAvailable: Bool
    ) -> Bool {
        false
    }
}

private final class MealSectionRenderSchedulerStub: MealSectionRenderScheduling {
    private let subject = PassthroughSubject<[MealSectionDisplayModel], Never>()

    var mealSectionsPublisher: AnyPublisher<[MealSectionDisplayModel], Never> {
        subject.eraseToAnyPublisher()
    }

    func render(input: MealSectionDisplayModelBuilder.Input, timing: MealSectionRenderTiming) {}
    func clear() {}
}

private struct FetchMyLikedMenusUseCaseStub: FetchMyLikedMenusUseCase {
    func execute() async throws -> [RestaurantLikedMenuGroup] { [] }
}

private struct GetMenuAlarmEnabledUseCaseStub: GetMenuAlarmEnabledUseCase {
    func execute() -> Bool { false }
}

private struct SetMenuAlarmEnabledUseCaseStub: SetMenuAlarmEnabledUseCase {
    func execute(_ isEnabled: Bool) {}
}

private struct UpdateMenuAlarmUseCaseStub: UpdateMenuAlarmUseCase {
    func execute(menuId: Int, isEnabled: Bool) async throws {}
}

private struct UpdateAllMenuAlarmsUseCaseStub: UpdateAllMenuAlarmsUseCase {
    func execute(isEnabled: Bool) async throws {}
}

private final class ControlledUpdateAllMenuAlarmsUseCase: UpdateAllMenuAlarmsUseCase {
    private var continuations: [CheckedContinuation<Void, Error>?] = []
    private(set) var executionCount = 0

    func execute(isEnabled: Bool) async throws {
        executionCount += 1
        try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func completeRequest(at index: Int) {
        continuations[index]?.resume()
        continuations[index] = nil
    }
}

private final class WeakReference<Value: AnyObject> {
    weak var value: Value?

    init(_ value: Value?) {
        self.value = value
    }
}

private struct UpdateMenuAlarmTimeUseCaseStub: UpdateMenuAlarmTimeUseCase {
    func execute(_ alarmTime: AlarmTime) async throws {}
}

private struct UpdateMenuLikeUseCaseStub: UpdateMenuLikeUseCase {
    func execute(menuId: Int, isLiked: Bool) async throws -> MenuLikeStatusModel {
        MenuLikeStatusModel(menuId: menuId, isLiked: isLiked, likeCount: 0)
    }
}

@MainActor
private final class MenuAlarmNotificationManagerStub: MenuAlarmNotificationManaging {
    func requestAuthorization() async -> Bool { true }
    func registerRemoteNotificationsIfNeeded() {}
    func didRegisterForRemoteNotifications(with deviceToken: Data) {}
    func didFailToRegisterForRemoteNotifications(error: Error) {}
}

private struct ResolveInitialAuthStateUseCaseStub: ResolveInitialAuthStateUseCase {
    func execute() async -> AuthState { .requiresLogin }
}

private struct CheckAppUpdateRequirementUseCaseStub: CheckAppUpdateRequirementUseCase {
    func execute(currentVersion: String) async -> AppUpdateRequirementResult { .updateNotRequired }
}
