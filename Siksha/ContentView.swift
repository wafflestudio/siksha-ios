//
//  ContentView.swift
//  Siksha
//
//  Created by 박종석 on 2021/01/31.
//

import SwiftUI

private extension ContentView {
    func tabBar(_ geometry: GeometryProxy) -> some View {
        HStack {
            Spacer()
            ForEach(self.tabItems) { item in
                Button(action: {
                    self.selectedTab = item.id
                }) {
                    Image((self.selectedTab == item.id ? item.buttonImage[0] : item.buttonImage[1]))
                        .renderingMode(.original)
                        .resizable()
                        .frame(width: 30, height: 30)
                }
                .padding(.bottom, geometry.safeAreaInsets.bottom)
                .transaction { transaction in
                    transaction.animation = nil
                    transaction.disablesAnimations = true
                }
                
                Spacer()
            }
        }
        .frame(width: geometry.size.width, height: 50 + geometry.safeAreaInsets.bottom)
        .background(Color.white.shadow(color: .init(white: 0.5), radius: 0, x: 0, y: -0.3))
        .padding(.top, -8)
        .padding(.bottom, -geometry.safeAreaInsets.bottom)
    }
}

// MARK: - Content View

struct ContentView: View {
    @State var selectedTab = 1
    @EnvironmentObject var appState: AppState
    
    struct TabItem: Identifiable {
        var id: Int
        
        var content: AnyView
        var buttonImage: [String]
    }
    
    let tabItems = FeatureFlag.shared.isEnabled(feature: .community) ? [
        TabItem(id: 0, content: AnyView(MenuView(isFavoriteTab: true).id("favorite")), buttonImage: ["Favorite", "Favorite-disabled"]),
        TabItem(id: 1, content: AnyView(MenuView().id("main")), buttonImage: ["Main", "Main-disabled"]),
        TabItem(id: 2, content: AnyView(CommunityView(viewModel: CommunityViewModel(communityRepository: DomainManager.shared.domain.communityRepository))), buttonImage: ["Community", "Community-disabled"]),
        TabItem(id: 3, content: AnyView(RenewalSettingsView(viewModel: RenewalSettingsViewModel())), buttonImage: ["Settings", "Settings-disabled"])
    ] : [
        TabItem(id: 0, content: AnyView(MenuView(isFavoriteTab: true).id("favorite")), buttonImage: ["Favorite", "Favorite-disabled"]),
        TabItem(id: 1, content: AnyView(MenuView().id("main")), buttonImage: ["Main", "Main-disabled"]),
        TabItem(id: 2, content: AnyView(SettingsView()), buttonImage: ["Settings", "Settings-disabled"])
    ]
  
    var body: some View {
            GeometryReader { geometry in
                NavigationView {
                    VStack {
                            
                            tabItems[selectedTab].content
                            
                            Spacer()
                            tabBar(geometry)
                            
                        
                    }
                      .ignoresSafeArea(.keyboard, edges: .bottom)
                    
                   
                }
                .navigationViewStyle(StackNavigationViewStyle())
            }
        
        
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
