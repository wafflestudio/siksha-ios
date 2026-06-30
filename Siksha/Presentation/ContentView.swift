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
        .padding(.bottom, geometry.safeAreaInsets.bottom == 0 ? geometry.safeAreaInsets.bottom + 13 : geometry.safeAreaInsets.bottom - 2)
        .background(
            Color.backgroundSecondary
                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: -2)
        )
    }
}

// MARK: - Content View
class ContentViewModel: ObservableObject {
    @Published var showPopUp = false
    @Published var popUpOpacity = 0.0
    @Published var showModal = !UserDefaults.standard.bool(forKey: "isAlreadyDisplayedMyLikedMenuModal")
    
    @Published var showMyMenuViewFromPopup = false
    static var contentViewModel = ContentViewModel()
    
}
struct ContentView: View {
    @State var selectedTab = 0
    @EnvironmentObject var appState: AppState
    @ObservedObject var contentViewModel = ContentViewModel.contentViewModel
    @StateObject private var menuViewModel = MenuViewModel(
        fetchDailyMenuUseCase: AppContainer.shared.useCases.fetchDailyMenuUseCase,
        fetchFestivalDatesUseCase: AppContainer.shared.useCases.fetchFestivalDatesUseCase,
        fetchRemoteConfigUseCase: AppContainer.shared.useCases.fetchRemoteConfigUseCase,
        observeRemoteConfigUseCase: AppContainer.shared.useCases.observeRemoteConfigUseCase,
        fetchPersonalRestaurantsUseCase: AppContainer.shared.useCases.fetchPersonalRestaurantsUseCase,
        updateRestaurantPreferenceUseCase: AppContainer.shared.useCases.updateRestaurantPreferenceUseCase,
        userPreferenceUseCase: AppContainer.shared.useCases.userPreferenceUseCase
    )
    @StateObject private var communityViewModel = CommunityViewModel(communityRepository: AppContainer.shared.domain.communityRepository)
    @StateObject private var settingsViewModel = RenewalSettingsViewModel(
        userPreferenceUseCase: AppContainer.shared.useCases.userPreferenceUseCase
    )
    @StateObject private var myLikedMenuViewModel = MyLikedMenuViewModel(
        myLikedMenuUseCase: AppContainer.shared.useCases.myLikedMenuUseCase,
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
    @State private var hidePopupWorkItem: DispatchWorkItem?
    @State private var previousSelectedTab = 0
    
    struct TabItem: Identifiable {
        var id: Int
        var content: AnyView
        var buttonImage: [String]
    }
    
    var tabItems: [TabItem] {
        [
            TabItem(id: 0, content: AnyView(MenuView(viewModel: menuViewModel).id("main")), buttonImage: ["Icons/Tabbar/main_orange", "Icons/Tabbar/main_grey"]),
            TabItem(id: 1, content: AnyView(CommunityView(viewModel: communityViewModel)), buttonImage: ["Icons/Tabbar/community_orange", "Icons/Tabbar/community_grey"]),
            TabItem(id: 2, content: AnyView(RenewalSettingsView(
                viewModel: settingsViewModel,
                orderViewModel: restaurantOrderViewModel
            )), buttonImage: ["Icons/Tabbar/settings_orange", "Icons/Tabbar/settings_grey"])
        ]
    }
    
    var body: some View {
        ZStack {
            NavigationStack {
                GeometryReader { geometry in
                    ZStack {
                        ZStack {
                            VStack(spacing:0) {
                                tabItems[selectedTab].content
                                tabBar(geometry)
                            }
                            .frame(width: geometry.size.width)
                            .ignoresSafeArea(.all, edges: .bottom)
                            
                            ZStack {
                                MyLikedMenuModal(viewModel: myLikedMenuViewModel)
                                    .environmentObject(ContentViewModel.contentViewModel)
                                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 7))
                            }
                            .ignoresSafeArea()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(Color.backgroundDim)
                            .zIndex(contentViewModel.showModal ? 10 : -10)
                            .opacity(contentViewModel.showModal ? 1 : 0)
                        }
                    }
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
                    Image("notificationPopup")
                        .offset(y: -(UIScreen.main.bounds.height / 2 - 97))
                        .offset(x: UIScreen.main.bounds.width / 2 - 80)
                        .opacity(contentViewModel.popUpOpacity)
                }
                .onAppear {
                    if UserDefaults.standard.integer(forKey: "alarmPopupCount") < 3 {
                        UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "alarmPopupCount") + 1, forKey: "alarmPopupCount")
                        hidePopupWorkItem = DispatchWorkItem {
                            withAnimation(.easeInOut(duration: 1.0)) {
                                contentViewModel.popUpOpacity = 0.0
                            }
                        }
                        
                        withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                            contentViewModel.popUpOpacity = 1.0
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: hidePopupWorkItem!)
                    }
                }
                .onChange(of: contentViewModel.showPopUp) { newValue in
                    if newValue == false {
                        hidePopupWorkItem?.cancel()
                        withTransaction(Transaction(animation: nil)) {
                            contentViewModel.popUpOpacity = 0.0
                        }
                    }
                }
            }
        }
        .onChange(of: selectedTab) { newTab in
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
