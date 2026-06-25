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

class MyLikedMenuViewModel: ObservableObject{
    private let myLikedMenuUseCase: MyLikedMenuUseCase
    private let menuAlarmUseCase: MenuAlarmUseCase
    private let updateMenuLikeUseCase: UpdateMenuLikeUseCase
    private let fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase
    private let updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase

    @Published var error: AppError?
    @Published var noAlarmPermission = false
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
    
    init(
        myLikedMenuUseCase: MyLikedMenuUseCase,
        menuAlarmUseCase: MenuAlarmUseCase,
        updateMenuLikeUseCase: UpdateMenuLikeUseCase,
        fetchPersonalRestaurantsUseCase: FetchPersonalRestaurantsUseCase = DefaultFetchPersonalRestaurantsUseCase(
            repository: RestaurantRepositoryImpl()
        ),
        updateRestaurantPreferenceUseCase: UpdateRestaurantPreferenceUseCase = DefaultUpdateRestaurantPreferenceUseCase(
            repository: RestaurantRepositoryImpl()
        )
    ) {
        self.myLikedMenuUseCase = myLikedMenuUseCase
        self.menuAlarmUseCase = menuAlarmUseCase
        self.updateMenuLikeUseCase = updateMenuLikeUseCase
        self.fetchPersonalRestaurantsUseCase = fetchPersonalRestaurantsUseCase
        self.updateRestaurantPreferenceUseCase = updateRestaurantPreferenceUseCase
        self.isAlarmEnabled = menuAlarmUseCase.getAlarmEnabled()
    }
    
    func failedAlarm() {
        print("errorALARM")
        error = AppError.unknownError("알람 오류가 발생했습니다.")
    }
    
    func setAlarmEnabled(_ enabled: Bool) {
        menuAlarmUseCase.setAlarmEnabled(enabled)
        isAlarmEnabled = enabled
    }
    
    func getAlarmTime() {
        Task { @MainActor [weak self] in
            await self?.refreshAlarmTime()
        }
    }
    
    @MainActor
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
    
    @MainActor
    private func refreshAlarmTime() async {
        do {
            alarmTime = try await menuAlarmUseCase.fetchAlarmTime()
        } catch {
            self.error = ErrorHelper.categorize(error)
        }
    }
    
    @MainActor
    private func loadMyLikedMenuItems() async -> MyLikedMenuLoadResult {
        do {
            let groups = try await myLikedMenuUseCase.fetchMyLikedMenus()
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
    
    @MainActor
    func toggleRestaurantFavorite(restaurantId: Int) async {
        guard !updatingFavoriteRestaurantIds.contains(restaurantId),
              let restaurant = personalRestaurantById[restaurantId] else {
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
    
    @MainActor
    private func refreshPersonalRestaurants() async {
        do {
            let restaurants = try await fetchPersonalRestaurantsUseCase.execute()
            personalRestaurantById = Dictionary(uniqueKeysWithValues: restaurants.map { ($0.id, $0) })
            personalRestaurantOrder = Dictionary(uniqueKeysWithValues: restaurants.enumerated().map { ($0.element.id, $0.offset) })
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
    
    private func isLikedMenu(menuId:Int)->Bool{
        menu(menuId: menuId)?.isLiked ?? false
    }
    
    private func updateMenuLikeStatus(_ status: MenuLikeStatusModel) {
        updateMenu(menuId: status.menuId) { menu in
            menu.isLiked = status.isLiked
            menu.likeCnt = status.likeCount
        }
    }
    
    private func toggleMenuAlarm(menuId:Int){
        updateMenu(menuId: menuId) { menu in
            menu.alarm.toggle()
        }
    }
    
    @MainActor
    private func toggleMenuLikePreference(menuId: Int) async {
        guard !updatingMenuLikeIds.contains(menuId) else {
            return
        }
        
        let isCurrentlyLiked = isLikedMenu(menuId: menuId)
        setUpdatingMenuLike(menuId, isUpdating: true)
        defer {
            setUpdatingMenuLike(menuId, isUpdating: false)
        }
        
        do {
            let status = try await updateMenuLikeUseCase.execute(
                menuId: menuId,
                isLiked: !isCurrentlyLiked
            )
            updateMenuLikeStatus(status)
        } catch {
            self.error = nil
            self.error = ErrorHelper.categorize(error)
        }
    }
    
    func toggleMenu(menuId: Int){
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            await toggleMenuLikePreference(menuId: menuId)
        }
    }
    func unLikedMenuCleanup(){
        for (i,_) in likedMenuGroups.enumerated(){
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
    private func isAlarmOn(menuId:Int)->Bool{
        menu(menuId: menuId)?.alarm ?? false
    }
    
    @MainActor
    private func turnOnAlarm(menuId:Int) async {
        do {
            try await menuAlarmUseCase.enableMenuAlarm(menuId: menuId)
            toggleMenuAlarm(menuId: menuId)
        } catch {
            self.error = ErrorHelper.categorize(error)
        }
    }
    
    private func enableAllAlarm(){
        for (i,_) in likedMenuGroups.enumerated(){
            for (j,_) in likedMenuGroups[i].menus.enumerated(){
                     likedMenuGroups[i].menus[j].alarm = true
                
            }
        }
    }
    private func disableAllAlarm(){
        for (i,_) in likedMenuGroups.enumerated(){
            for (j,_) in likedMenuGroups[i].menus.enumerated(){
                     likedMenuGroups[i].menus[j].alarm = false
                
            }
        }
    }
    
    @MainActor
    private func turnOffAlarm(menuId:Int) async {
        do {
            try await menuAlarmUseCase.disableMenuAlarm(menuId: menuId)
            toggleMenuAlarm(menuId: menuId)
        } catch {
            self.error = ErrorHelper.categorize(error)
        }
    }
    
    func toggleAlarm(menuId:Int){
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            if isAlarmOn(menuId: menuId) {
                await turnOffAlarm(menuId: menuId)
            } else {
                await turnOnAlarm(menuId: menuId)
            }
        }
    }
    
    func enableAlarm(){
        Task { @MainActor [weak self] in
            await self?.enableAlarmAsync()
        }
    }
    
    @MainActor
    private func enableAlarmAsync() async {
        do {
            try await menuAlarmUseCase.enableAllMenuAlarms()
            
            withAnimation(.easeOut(duration: 0.3)) {
                isAlarmEnabled = true
                enableAllAlarm()
            }
        } catch {
            print("ERROR")
            print(error)
            self.error = ErrorHelper.categorize(error)
        }
    }

    @MainActor
    private func disableAlarm() async {
        do {
            try await menuAlarmUseCase.disableAllMenuAlarms()
            
            withAnimation(.easeOut(duration: 0.3)) {
                isAlarmEnabled = false
                disableAllAlarm()
            }
        } catch {
            self.error = ErrorHelper.categorize(error)
        }
    }
    
    func toggleAlarmEnabled(){
        
        if isAlarmEnabled{
            Task { @MainActor [weak self] in
                await self?.disableAlarm()
            }
        }
        else{
            AppDelegate.alarmViewModel = self
            AppDelegate.requestNotificationPermission()
        }
    }
    
    func toggleAlarmTime(){
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            let nextAlarmTime = alarmTime == .EVERY_MEAL ? AlarmTime.DAILY : AlarmTime.EVERY_MEAL
            
            do {
                try await menuAlarmUseCase.updateAlarmTime(nextAlarmTime)
                alarmTime = nextAlarmTime
            } catch {
                self.error = ErrorHelper.categorize(error)
            }
        }
    }
}
