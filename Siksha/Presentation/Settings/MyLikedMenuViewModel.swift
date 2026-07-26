//
//  MyLikedMenuViewModel.swift
//  Siksha
//
//  Created by 박정헌 on 9/18/25.
//

import Foundation
import SwiftUI

enum MyLikedMenuLoadState {
    case idle
    case loading
    case loaded
    case failed
}

private enum MyLikedMenuLoadResult {
    case succeeded
    case cancelled
    case failed
}

@MainActor
final class MyLikedMenuViewModel: ObservableObject {
    private let fetchMyLikedMenusUseCase: FetchMyLikedMenusUseCase
    private let getMenuAlarmEnabledUseCase: GetMenuAlarmEnabledUseCase
    private let setMenuAlarmEnabledUseCase: SetMenuAlarmEnabledUseCase
    private let updateMenuAlarmUseCase: UpdateMenuAlarmUseCase
    private let updateAllMenuAlarmsUseCase: UpdateAllMenuAlarmsUseCase
    private let fetchMenuAlarmTimeUseCase: FetchMenuAlarmTimeUseCase
    private let updateMenuAlarmTimeUseCase: UpdateMenuAlarmTimeUseCase
    private let updateMenuLikeUseCase: UpdateMenuLikeUseCase
    private let menuAlarmNotificationManager: MenuAlarmNotificationManaging
    private let fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase
    private let updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase

    @Published var error: AppError?
    @Published var noAlarmPermission = false
    @Published private(set) var isUpdatingAlarmEnabled = false
    @Published var isAlarmEnabled: Bool
    @Published var likedMenuGroups: [RestaurantLikedMenuGroup] = []
    @Published private(set) var loadState: MyLikedMenuLoadState = .idle
    @Published private var personalRestaurantById: [Int: PersonalRestaurantModel] = [:]
    @Published private var updatingFavoriteRestaurantIds: Set<Int> = []
    @Published private var updatingMenuLikeIds: Set<Int> = []
    @Published var alarmTime: AlarmTime = .DAILY
    private var personalRestaurantOrder: [Int: Int] = [:]
    private var initErrorCount = 0
    private var isLoadingLikedMenus = false
    private var hasLoadedLikedMenus = false
    private var alarmEnabledChangeTask: Task<Void, Never>?
    private var alarmEnabledChangeGeneration = 0
    private var alarmTimeFetchTask: Task<Void, Never>?
    private var alarmTimeUpdateTask: Task<Void, Never>?
    private var menuLikeTasks: [Int: Task<Void, Never>] = [:]
    private var menuAlarmTasks: [Int: Task<Void, Never>] = [:]
    private var updatingMenuAlarmIds: Set<Int> = []

    init(
        fetchMyLikedMenusUseCase: FetchMyLikedMenusUseCase,
        getMenuAlarmEnabledUseCase: GetMenuAlarmEnabledUseCase,
        setMenuAlarmEnabledUseCase: SetMenuAlarmEnabledUseCase,
        updateMenuAlarmUseCase: UpdateMenuAlarmUseCase,
        updateAllMenuAlarmsUseCase: UpdateAllMenuAlarmsUseCase,
        fetchMenuAlarmTimeUseCase: FetchMenuAlarmTimeUseCase,
        updateMenuAlarmTimeUseCase: UpdateMenuAlarmTimeUseCase,
        updateMenuLikeUseCase: UpdateMenuLikeUseCase,
        menuAlarmNotificationManager: MenuAlarmNotificationManaging,
        fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase,
        updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase
    ) {
        self.fetchMyLikedMenusUseCase = fetchMyLikedMenusUseCase
        self.getMenuAlarmEnabledUseCase = getMenuAlarmEnabledUseCase
        self.setMenuAlarmEnabledUseCase = setMenuAlarmEnabledUseCase
        self.updateMenuAlarmUseCase = updateMenuAlarmUseCase
        self.updateAllMenuAlarmsUseCase = updateAllMenuAlarmsUseCase
        self.fetchMenuAlarmTimeUseCase = fetchMenuAlarmTimeUseCase
        self.updateMenuAlarmTimeUseCase = updateMenuAlarmTimeUseCase
        self.updateMenuLikeUseCase = updateMenuLikeUseCase
        self.menuAlarmNotificationManager = menuAlarmNotificationManager
        self.fetchPersonalRestaurantsUseCase = fetchPersonalRestaurantsUseCase
        self.updateRestaurantPreferenceUseCase = updateRestaurantPreferenceUseCase
        self.isAlarmEnabled = getMenuAlarmEnabledUseCase.execute()
    }

    deinit {
        alarmEnabledChangeTask?.cancel()
        alarmTimeFetchTask?.cancel()
        alarmTimeUpdateTask?.cancel()
        menuLikeTasks.values.forEach { $0.cancel() }
        menuAlarmTasks.values.forEach { $0.cancel() }
    }

    func setAlarmEnabled(_ enabled: Bool) {
        alarmEnabledChangeGeneration += 1
        alarmEnabledChangeTask?.cancel()
        isUpdatingAlarmEnabled = false
        setMenuAlarmEnabledUseCase.execute(enabled)
        isAlarmEnabled = enabled
    }

    func requestAlarmEnabledChange(_ enabled: Bool) {
        guard enabled != isAlarmEnabled, !isUpdatingAlarmEnabled else {
            return
        }

        isUpdatingAlarmEnabled = true
        alarmEnabledChangeTask?.cancel()
        alarmEnabledChangeGeneration += 1
        let generation = alarmEnabledChangeGeneration
        let updateAllMenuAlarmsUseCase = updateAllMenuAlarmsUseCase
        if enabled {
            let menuAlarmNotificationManager = menuAlarmNotificationManager
            alarmEnabledChangeTask = Task { [weak self] in
                let isGranted = await menuAlarmNotificationManager.requestAuthorization()
                guard !Task.isCancelled else {
                    if self?.alarmEnabledChangeGeneration == generation {
                        self?.isUpdatingAlarmEnabled = false
                    }
                    return
                }
                guard isGranted else {
                    guard let self, self.alarmEnabledChangeGeneration == generation else { return }
                    noAlarmPermission = true
                    isUpdatingAlarmEnabled = false
                    return
                }

                do {
                    try await updateAllMenuAlarmsUseCase.execute(isEnabled: true)
                    try Task.checkCancellation()
                    guard let self, self.alarmEnabledChangeGeneration == generation else { return }

                    withAnimation(.easeOut(duration: 0.3)) {
                        self.isAlarmEnabled = true
                        self.enableAllAlarm()
                    }
                    isUpdatingAlarmEnabled = false
                    menuAlarmNotificationManager.registerRemoteNotificationsIfNeeded()
                } catch {
                    guard let self, self.alarmEnabledChangeGeneration == generation else { return }
                    isUpdatingAlarmEnabled = false
                    guard !(error is CancellationError) else { return }
                    self.error = ErrorHelper.categorize(error)
                }
            }
        } else {
            alarmEnabledChangeTask = Task { [weak self] in
                do {
                    try await updateAllMenuAlarmsUseCase.execute(isEnabled: false)
                    try Task.checkCancellation()
                    guard let self, self.alarmEnabledChangeGeneration == generation else { return }

                    withAnimation(.easeOut(duration: 0.3)) {
                        self.isAlarmEnabled = false
                        self.disableAllAlarm()
                    }
                    isUpdatingAlarmEnabled = false
                } catch {
                    guard let self, self.alarmEnabledChangeGeneration == generation else { return }
                    isUpdatingAlarmEnabled = false
                    guard !(error is CancellationError) else { return }
                    self.error = ErrorHelper.categorize(error)
                }
            }
        }
    }

    func getAlarmTime() {
        alarmTimeFetchTask?.cancel()
        let fetchMenuAlarmTimeUseCase = fetchMenuAlarmTimeUseCase
        alarmTimeFetchTask = Task { [weak self] in
            do {
                let fetchedAlarmTime = try await fetchMenuAlarmTimeUseCase.execute()
                try Task.checkCancellation()
                self?.alarmTime = fetchedAlarmTime
            } catch {
                guard !(error is CancellationError) else { return }
                self?.error = ErrorHelper.categorize(error)
            }
        }
    }

    func loadMyLikedMenu() async {
        guard !isLoadingLikedMenus, !hasLoadedLikedMenus else {
            return
        }

        isLoadingLikedMenus = true
        loadState = .loading
        defer {
            isLoadingLikedMenus = false
        }

        await refreshPersonalRestaurants()
        guard !Task.isCancelled else {
            loadState = .idle
            return
        }

        switch await loadMyLikedMenuItems() {
        case .succeeded:
            hasLoadedLikedMenus = true
            loadState = .loaded
        case .cancelled:
            loadState = .idle
        case .failed:
            loadState = .failed
        }
    }

    private func loadMyLikedMenuItems() async -> MyLikedMenuLoadResult {
        do {
            let groups = try await fetchMyLikedMenusUseCase.execute()
            likedMenuGroups = sortByPersonalRestaurantOrder(groups)
            initErrorCount = 0
            return .succeeded
        } catch {
            if error is CancellationError {
                return .cancelled
            }

            if initErrorCount == 0 { // 알람 화면에서 뒤로 갈 때 알람이 떠서 잘 안 돌아가지는 문제 해결용
                self.error = ErrorHelper.categorize(error)
            }
            initErrorCount += 1
            return .failed
        }
    }

    func isFavoriteRestaurant(restaurantId: Int) -> Bool {
        personalRestaurantById[restaurantId]?.liked ?? false
    }

    func isUpdatingFavoriteRestaurant(restaurantId: Int) -> Bool {
        updatingFavoriteRestaurantIds.contains(restaurantId)
    }

    func isUpdatingMenuLike(menuId: Int) -> Bool {
        updatingMenuLikeIds.contains(menuId)
    }

    func toggleRestaurantFavorite(restaurantId: Int) async {
        guard !updatingFavoriteRestaurantIds.contains(restaurantId),
            let restaurant = personalRestaurantById[restaurantId]
        else {
            return
        }

        setUpdatingFavoriteRestaurant(restaurantId, isUpdating: true)
        defer {
            setUpdatingFavoriteRestaurant(restaurantId, isUpdating: false)
        }

        do {
            let status = try await updateRestaurantPreferenceUseCase.setLiked(
                restaurant: restaurant,
                liked: !restaurant.liked
            )
            updatePersonalRestaurant(status)
        } catch {
            self.error = ErrorHelper.categorize(error)
        }
    }

    private func refreshPersonalRestaurants() async {
        do {
            let restaurants = try await fetchPersonalRestaurantsUseCase.execute()
            personalRestaurantById = Dictionary(uniqueKeysWithValues: restaurants.map { ($0.id, $0) })
            personalRestaurantOrder = Dictionary(
                uniqueKeysWithValues: restaurants.enumerated().map { ($0.element.id, $0.offset) })
        } catch {
            if error is CancellationError {
                return
            }

            self.error = ErrorHelper.categorize(error)
        }
    }

    private func updatePersonalRestaurant(_ status: RestaurantPreferenceStatusModel) {
        guard let restaurant = personalRestaurantById[status.id] else {
            return
        }

        var restaurants = personalRestaurantById
        restaurants[status.id] = PersonalRestaurantModel(
            id: restaurant.id,
            code: restaurant.code,
            nameKr: restaurant.nameKr,
            nameEn: restaurant.nameEn,
            address: restaurant.address,
            coordinate: restaurant.coordinate,
            liked: status.liked,
            visible: status.visible,
            operatingHours: restaurant.operatingHours
        )
        personalRestaurantById = restaurants
    }

    private func setUpdatingFavoriteRestaurant(_ restaurantId: Int, isUpdating: Bool) {
        var restaurantIds = updatingFavoriteRestaurantIds
        if isUpdating {
            restaurantIds.insert(restaurantId)
        } else {
            restaurantIds.remove(restaurantId)
        }
        updatingFavoriteRestaurantIds = restaurantIds
    }

    private func setUpdatingMenuLike(_ menuId: Int, isUpdating: Bool) {
        var menuIds = updatingMenuLikeIds
        if isUpdating {
            menuIds.insert(menuId)
        } else {
            menuIds.remove(menuId)
        }
        updatingMenuLikeIds = menuIds
    }

    private func sortByPersonalRestaurantOrder(_ groups: [RestaurantLikedMenuGroup]) -> [RestaurantLikedMenuGroup] {
        groups.sorted {
            let lhsIndex = personalRestaurantOrder[$0.id] ?? Int.max
            let rhsIndex = personalRestaurantOrder[$1.id] ?? Int.max

            if lhsIndex == rhsIndex {
                return $0.id < $1.id
            }
            return lhsIndex < rhsIndex
        }
    }

    private func menu(menuId: Int) -> MyLikedMenu? {
        for group in likedMenuGroups {
            if let menu = group.menus.first(where: { $0.id == menuId }) {
                return menu
            }
        }
        return nil
    }

    private func updateMenu(menuId: Int, transform: (inout MyLikedMenu) -> Void) {
        for groupIndex in likedMenuGroups.indices {
            guard let menuIndex = likedMenuGroups[groupIndex].menus.firstIndex(where: { $0.id == menuId }) else {
                continue
            }

            transform(&likedMenuGroups[groupIndex].menus[menuIndex])
            return
        }
    }

    private func isLikedMenu(menuId: Int) -> Bool {
        menu(menuId: menuId)?.isLiked ?? false
    }

    private func updateMenuLikeStatus(_ status: MenuLikeStatusModel) {
        updateMenu(menuId: status.menuId) { menu in
            menu.isLiked = status.isLiked
            menu.likeCnt = status.likeCount
        }
    }

    private func toggleMenuAlarm(menuId: Int) {
        updateMenu(menuId: menuId) { menu in
            menu.alarm.toggle()
        }
    }

    func toggleMenu(menuId: Int) {
        guard !updatingMenuLikeIds.contains(menuId) else {
            return
        }

        let isCurrentlyLiked = isLikedMenu(menuId: menuId)
        let updateMenuLikeUseCase = updateMenuLikeUseCase
        setUpdatingMenuLike(menuId, isUpdating: true)
        menuLikeTasks[menuId] = Task { [weak self] in
            do {
                let status = try await updateMenuLikeUseCase.execute(
                    menuId: menuId,
                    isLiked: !isCurrentlyLiked
                )
                try Task.checkCancellation()
                self?.updateMenuLikeStatus(status)
            } catch {
                if !(error is CancellationError) {
                    self?.error = ErrorHelper.categorize(error)
                }
            }
            self?.setUpdatingMenuLike(menuId, isUpdating: false)
        }
    }
    func unLikedMenuCleanup() {
        for (i, _) in likedMenuGroups.enumerated() {
            likedMenuGroups[i].menus.removeAll(where: {
                menu in
                !menu.isLiked
            })
        }
        likedMenuGroups.removeAll(where: {
            group in
            group.menus.isEmpty
        })
    }
    private func isAlarmOn(menuId: Int) -> Bool {
        menu(menuId: menuId)?.alarm ?? false
    }

    private func enableAllAlarm() {
        for (i, _) in likedMenuGroups.enumerated() {
            for (j, _) in likedMenuGroups[i].menus.enumerated() {
                likedMenuGroups[i].menus[j].alarm = true

            }
        }
    }
    private func disableAllAlarm() {
        for (i, _) in likedMenuGroups.enumerated() {
            for (j, _) in likedMenuGroups[i].menus.enumerated() {
                likedMenuGroups[i].menus[j].alarm = false

            }
        }
    }

    func toggleAlarm(menuId: Int) {
        guard !updatingMenuAlarmIds.contains(menuId) else {
            return
        }

        let isEnabled = !isAlarmOn(menuId: menuId)
        let updateMenuAlarmUseCase = updateMenuAlarmUseCase
        updatingMenuAlarmIds.insert(menuId)
        menuAlarmTasks[menuId] = Task { [weak self] in
            do {
                try await updateMenuAlarmUseCase.execute(menuId: menuId, isEnabled: isEnabled)
                try Task.checkCancellation()
                self?.toggleMenuAlarm(menuId: menuId)
            } catch {
                if !(error is CancellationError) {
                    self?.error = ErrorHelper.categorize(error)
                }
            }
            self?.updatingMenuAlarmIds.remove(menuId)
        }
    }

    func toggleAlarmEnabled() {
        requestAlarmEnabledChange(!isAlarmEnabled)
    }

    func toggleAlarmTime() {
        alarmTimeUpdateTask?.cancel()
        let nextAlarmTime = alarmTime == .EVERY_MEAL ? AlarmTime.DAILY : AlarmTime.EVERY_MEAL
        let updateMenuAlarmTimeUseCase = updateMenuAlarmTimeUseCase
        alarmTimeUpdateTask = Task { [weak self] in
            do {
                try await updateMenuAlarmTimeUseCase.execute(nextAlarmTime)
                try Task.checkCancellation()
                self?.alarmTime = nextAlarmTime
            } catch {
                if !(error is CancellationError) {
                    self?.error = ErrorHelper.categorize(error)
                }
            }
        }
    }
}
