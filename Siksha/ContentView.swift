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
class ContentViewModel:ObservableObject{
    @Published var showPopUp = false
    @Published var popUpOpacity = 0.0
    @Published var showModal =                        !UserDefaults.standard.bool(forKey: "isAlreadyDisplayedMyLikedMenuModal")

    @Published var showMyMenuViewFromPopup = false
    static var contentViewModel = ContentViewModel()
    
}
struct ContentView: View {
    @State var selectedTab = 1
    @EnvironmentObject var appState: AppState
    @State var showPopup = false
    @State var popUpOpacity = 0.0
    @ObservedObject var contentViewModel = ContentViewModel.contentViewModel
    @StateObject var alarmViewModel = MyLikedMenuViewModel(myLikedMenuRepository: DomainManager.shared.domain.myLikedMenuRepository)
    struct TabItem: Identifiable {
        var id: Int
        var content: AnyView
        var buttonImage: [String]
    }
    
    let tabItems = [
        TabItem(id: 0, content: AnyView(MenuView(isFavoriteTab: true).id("favorite")), buttonImage: ["Favorite", "Favorite-disabled"]),
        TabItem(id: 1, content: AnyView(MenuView().id("main")), buttonImage: ["Main", "Main-disabled"]),
        TabItem(id: 2, content: AnyView(CommunityView(viewModel: CommunityViewModel(communityRepository: DomainManager.shared.domain.communityRepository))), buttonImage: ["Community", "Community-disabled"]),
        TabItem(id: 3, content: AnyView(RenewalSettingsView(viewModel: RenewalSettingsViewModel())), buttonImage: ["Settings", "Settings-disabled"])
    ]
    
    var body: some View {
    
            GeometryReader { geometry in
                ZStack{
                    NavigationView {
                        ZStack{
                            VStack(spacing:0) {
                                
                                tabItems[selectedTab].content
                                
                                tabBar(geometry)
                                
                                
                            }
                            .frame(width:geometry.size.width)
                            .ignoresSafeArea(.all, edges: .bottom)
                            
                                ZStack{
                                    MyLikedMenuModal( viewModel: alarmViewModel)
                                        .environmentObject(ContentViewModel.contentViewModel)
                                        .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 7))
                                    
                                }
                                .ignoresSafeArea()
                                .frame(maxWidth:.infinity,maxHeight:.infinity)
                                .background(Color.backgroundDim)
                                .zIndex(contentViewModel.showModal ? 10 : -10)
                                .opacity(contentViewModel.showModal ? 1 :0)
                            }
                            NavigationLink(destination: MyLikedMenuView(viewModel: MyLikedMenuViewModel(myLikedMenuRepository: DomainManager.shared.domain.myLikedMenuRepository)),isActive: $contentViewModel.showMyMenuViewFromPopup){
                                EmptyView()
                            }
                        
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                 
                    if contentViewModel.showPopUp{
                        ZStack(alignment: .topTrailing) {
                            Image("notificationPopup")
                               .offset(y: -(UIScreen.main.bounds.height/2-97))
                               .offset(x: UIScreen.main.bounds.width/2-80)
                               .opacity(contentViewModel.popUpOpacity)
                        }
                        .onAppear{
                            print("onappear")
                            if UserDefaults.standard.integer(forKey: "alarmPopupCount") < 3{
                                withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                                    contentViewModel.popUpOpacity = 1.0
                                }
                                
                                withAnimation(.easeInOut(duration: 1.0).delay(5.0)) {
                                    contentViewModel.popUpOpacity = 0.0
                                    UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "alarmPopupCount") + 1,forKey: "alarmPopupCount")
                                }
                            }
                        }
                    }
                    
                }
                .onAppear{
                    print("CONTENTVIEW")
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }


/*
=======
        GeometryReader { geometry in
            NavigationStack {
                VStack(spacing: 0) {
                    tabItems[selectedTab].content
                    tabBar(geometry)
                }
                .frame(width: geometry.size.width)
                .ignoresSafeArea(.all, edges: .bottom)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        }
>>>>>>> develop*/
    }
}

// MARK: - Preview

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension View{
    @ViewBuilder
    func If<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
