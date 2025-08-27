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
                        .frame(width: 36, height: 46)
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
        .background(Color.backgroundSecondary.shadow(color:Color(red: 0, green: 0, blue: 0,opacity: 0.05), radius: 0, x: 0, y: -0.3))
        .padding(.top, -8)
        .padding(.bottom, -geometry.safeAreaInsets.bottom)
    }
}

// MARK: - Content View
class PopUpObject:ObservableObject{
    @Published var showPopUp = false
    @Published var popUpOpacity = 0.0
    static var popUpObject = PopUpObject()
}
struct ContentView: View {
    @State var selectedTab = 1
    @EnvironmentObject var appState: AppState
    @State var showPopup = false
    @State var popUpOpacity = 0.0
    @ObservedObject var popUpObject = PopUpObject.popUpObject
    struct TabItem: Identifiable {
        var id: Int
        
        var content: AnyView
        var buttonImage: [String]
    }
    
    let tabItems =
        [TabItem(id: 0, content: AnyView(MenuView(isFavoriteTab: true).id("favorite")), buttonImage: ["Favorite", "Favorite-disabled"]),
        TabItem(id: 1, content: AnyView(MenuView().id("main")), buttonImage: ["Main", "Main-disabled"]),
        TabItem(id: 2, content: AnyView(CommunityView(viewModel: CommunityViewModel(communityRepository: DomainManager.shared.domain.communityRepository))), buttonImage: ["Community", "Community-disabled"]),
         TabItem(id: 3, content: AnyView(RenewalSettingsView(viewModel: RenewalSettingsViewModel())), buttonImage: ["Settings", "Settings-disabled"])
        ]
    
  
    var body: some View {
    
            GeometryReader { geometry in
                ZStack{
                    NavigationView {
                        VStack {
                            
                            tabItems[selectedTab].content
                            
                            Spacer()
                            tabBar(geometry)
                            
                            
                        }
                        .ignoresSafeArea(.keyboard, edges: .bottom)
                        
                        
                    }
                    .navigationViewStyle(StackNavigationViewStyle())
                    if popUpObject.showPopUp{
                        ZStack(alignment: .topTrailing) {
                            Image("notificationPopup")
                               .offset(y: -(UIScreen.main.bounds.height/2-97))
                               .offset(x: UIScreen.main.bounds.width/2-80)
                               .opacity(popUpObject.popUpOpacity)
                        }
                        .onAppear{
                            print("onappear")
                            withAnimation(.easeInOut(duration: 1.0).delay(0.5)) {
                                popUpObject.popUpOpacity = 1.0
                            }
                            
                            withAnimation(.easeInOut(duration: 1.0).delay(5.0)) {
                               popUpObject.popUpOpacity = 0.0
                            }
                         
                        }
                    }
                    
                }
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
