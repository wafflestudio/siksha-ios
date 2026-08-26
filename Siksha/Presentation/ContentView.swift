//
//  ContentView.swift
//  Siksha
//
//  Created by 박종석 on 2021/01/31.
//

import SwiftUI

private extension ContentView {
    func tabBar(_ geometry: GeometryProxy) -> some View {
        HStack(spacing: 48) {
            Spacer()
            ForEach(self.tabItems) { item in
                Button(action: {
                    self.selectedTab = item.id
                }) {
                    Image((self.selectedTab == item.id ? item.buttonImage[0] : item.buttonImage[1]))
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 36, height: 46)
                }
                .transaction { transaction in
                    transaction.animation = nil
                    transaction.disablesAnimations = true
                }
            }
            Spacer()
        }
        .padding(.top, 5)
        .padding(
            .bottom,
            geometry.safeAreaInsets.bottom == 0
                ? geometry.safeAreaInsets.bottom + 13
                : geometry.safeAreaInsets.bottom - 2
        )
        .background(
            Color.backgroundSecondary
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: -2)
        )
    }
}

// MARK: - Content View
@MainActor
final class ContentViewModel: ObservableObject {
    @Published var showPopUp = false
    @Published var popUpOpacity = 0.0
    @Published var showModal: Bool
    @Published var showMyMenuViewFromPopup = false

    private let userDefaults: UserDefaults
    private let popupDismissDelayNanoseconds: UInt64
    private var popupDismissTask: Task<Void, Never>?

    init(
        userDefaults: UserDefaults = .standard,
        popupDismissDelayNanoseconds: UInt64 = 5_000_000_000
    ) {
        self.userDefaults = userDefaults
        self.popupDismissDelayNanoseconds = popupDismissDelayNanoseconds
        self.showModal = !userDefaults.bool(forKey: "isAlreadyDisplayedMyLikedMenuModal")
    }

    func schedulePopupDismissalIfNeeded() {
        let popupCountKey = "alarmPopupCount"
        guard userDefaults.integer(forKey: popupCountKey) < 3 else {
            return
        }

        userDefaults.set(userDefaults.integer(forKey: popupCountKey) + 1, forKey: popupCountKey)
        popupDismissTask?.cancel()

        withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
            popUpOpacity = 1.0
        }

        let popupDismissDelayNanoseconds = popupDismissDelayNanoseconds
        popupDismissTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: popupDismissDelayNanoseconds)
                try Task.checkCancellation()
                withAnimation(.easeInOut(duration: 1.0)) {
                    self?.popUpOpacity = 0.0
                }
            } catch {
                return
            }
        }
    }

    func cancelPopupDismissal() {
        popupDismissTask?.cancel()
        withTransaction(Transaction(animation: nil)) {
            popUpOpacity = 0.0
        }
    }

    deinit {
        popupDismissTask?.cancel()
    }
}
struct ContentView: View {
    @State var selectedTab = 0
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var contentViewModel: ContentViewModel
    @StateObject private var menuViewModel = MenuViewModel(
        fetchDailyMenuUseCase: AppContainer.shared.useCases.fetchDailyMenuUseCase,
        fetchFestivalDatesUseCase: AppContainer.shared.useCases.fetchFestivalDatesUseCase,
        fetchRemoteConfigUseCase: AppContainer.shared.useCases.fetchRemoteConfigUseCase,
        observeRemoteConfigUseCase: AppContainer.shared.useCases.observeRemoteConfigUseCase,
        fetchPersonalRestaurantsUseCase: AppContainer.shared.useCases.fetchPersonalRestaurantsUseCase,
        updateRestaurantPreferenceUseCase: AppContainer.shared.useCases.updateRestaurantPreferenceUseCase,
        manageMenuFiltersUseCase: AppContainer.shared.useCases.manageMenuFiltersUseCase,
        manageRestaurantsWithoutMenuVisibilityUseCase: AppContainer.shared.useCases
            .manageRestaurantsWithoutMenuVisibilityUseCase,
        manageFestivalPreferencesUseCase: AppContainer.shared.useCases.manageFestivalPreferencesUseCase,
        checkFestivalSwitchVisibilityUseCase: AppContainer.shared.useCases.checkFestivalSwitchVisibilityUseCase
    )
    @StateObject private var communityViewModel = CommunityViewModel(
        communityRepository: AppContainer.shared.domain.communityRepository,
        blockManager: AppContainer.shared.blockManager
    )
    @StateObject private var settingsViewModel = RenewalSettingsViewModel(
        manageRestaurantsWithoutMenuVisibilityUseCase: AppContainer.shared.useCases
            .manageRestaurantsWithoutMenuVisibilityUseCase,
        fetchCurrentUserUseCase: AppContainer.shared.useCases.fetchCurrentUserUseCase,
        submitVOCUseCase: AppContainer.shared.useCases.submitVOCUseCase,
        fetchAppStoreVersionUseCase: AppContainer.shared.useCases.fetchAppStoreVersionUseCase
    )
    @StateObject private var myLikedMenuViewModel = MyLikedMenuViewModel(
        fetchMyLikedMenusUseCase: AppContainer.shared.useCases.fetchMyLikedMenusUseCase,
        getMenuAlarmEnabledUseCase: AppContainer.shared.useCases.getMenuAlarmEnabledUseCase,
        setMenuAlarmEnabledUseCase: AppContainer.shared.useCases.setMenuAlarmEnabledUseCase,
        updateMenuAlarmUseCase: AppContainer.shared.useCases.updateMenuAlarmUseCase,
        updateAllMenuAlarmsUseCase: AppContainer.shared.useCases.updateAllMenuAlarmsUseCase,
        fetchMenuAlarmTimeUseCase: AppContainer.shared.useCases.fetchMenuAlarmTimeUseCase,
        updateMenuAlarmTimeUseCase: AppContainer.shared.useCases.updateMenuAlarmTimeUseCase,
        updateMenuLikeUseCase: AppContainer.shared.useCases.updateMenuLikeUseCase,
        menuAlarmNotificationManager: AppContainer.shared.menuAlarmNotificationManager,
        fetchPersonalRestaurantsUseCase: AppContainer.shared.useCases.fetchPersonalRestaurantsUseCase,
        updateRestaurantPreferenceUseCase: AppContainer.shared.useCases.updateRestaurantPreferenceUseCase
    )
    @StateObject private var restaurantOrderViewModel = RestaurantOrderViewModel(
        fetchPersonalRestaurantsUseCase: AppContainer.shared.useCases.fetchPersonalRestaurantsUseCase,
        updateRestaurantPreferenceUseCase: AppContainer.shared.useCases.updateRestaurantPreferenceUseCase,
        setRestaurantOrderUseCase: AppContainer.shared.useCases.setRestaurantOrderUseCase
    )
    @State private var previousSelectedTab = 0

    struct TabItem: Identifiable {
        var id: Int
        var content: AnyView
        var buttonImage: [String]
    }

    var tabItems: [TabItem] {
        [
            TabItem(
                id: 0, content: AnyView(MenuView(viewModel: menuViewModel).id("main")),
                buttonImage: ["Icons/Tabbar/main_orange", "Icons/Tabbar/main_grey"]),
            TabItem(
                id: 1, content: AnyView(CommunityView(viewModel: communityViewModel)),
                buttonImage: ["Icons/Tabbar/community_orange", "Icons/Tabbar/community_grey"]),
            TabItem(
                id: 2,
                content: AnyView(
                    RenewalSettingsView(
                        viewModel: settingsViewModel,
                        orderViewModel: restaurantOrderViewModel
                    )), buttonImage: ["Icons/Tabbar/settings_orange", "Icons/Tabbar/settings_grey"]),
        ]
    }

    var body: some View {
        ZStack {
            NavigationStack {
                GeometryReader { geometry in
                    ZStack {
                        ZStack {
                            VStack(spacing: 0) {
                                tabItems[selectedTab].content
                                tabBar(geometry)
                            }
                            .frame(width: geometry.size.width)
                            .ignoresSafeArea(.all, edges: .bottom)

                            ZStack {
                                MyLikedMenuModal(viewModel: myLikedMenuViewModel)
                                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 7))
                            }
                            .ignoresSafeArea()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.backgroundDim)
                            .zIndex(contentViewModel.showModal ? 10 : -10)
                            .opacity(contentViewModel.showModal ? 1 : 0)
                        }
                    }
                    .environment(\.safeAreaInsets, geometry.safeAreaInsets)
                    .onAppear {
                        AppContainer.shared.menuAlarmNotificationManager.registerRemoteNotificationsIfNeeded()
                    }
                    .navigationDestination(isPresented: $contentViewModel.showMyMenuViewFromPopup) {
                        MyLikedMenuView(viewModel: myLikedMenuViewModel)
                    }
                }
            }

            if contentViewModel.showPopUp {
                ZStack(alignment: .topTrailing) {
                    Image(.Images.notificationPopup)
                        .offset(y: -(UIScreen.main.bounds.height / 2 - 97))
                        .offset(x: UIScreen.main.bounds.width / 2 - 80)
                        .opacity(contentViewModel.popUpOpacity)
                }
                .onAppear {
                    contentViewModel.schedulePopupDismissalIfNeeded()
                }
                .onChange(of: contentViewModel.showPopUp) { _, newValue in
                    if newValue == false {
                        contentViewModel.cancelPopupDismissal()
                    }
                }
            }
        }
        .onChange(of: selectedTab) { _, newTab in
            if previousSelectedTab != 0 && newTab == 0 {
                menuViewModel.refreshPersonalRestaurants()
            }
            previousSelectedTab = newTab
        }
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AppState())
            .environmentObject(ContentViewModel())
    }
}

extension View {
    @ViewBuilder
    func If<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
