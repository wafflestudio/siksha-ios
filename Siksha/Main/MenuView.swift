//
//  MenuView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI

private extension MenuView {
    func typeButton(type: TypeInfo) -> some View {
        Button(action: {
            viewModel.selectedPage = type.id
        }) {
            VStack {
                Image(type.icon)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: type.width, height: type.height)
                    .foregroundColor(viewModel.selectedPage == type.id ? orangeColor : lightGrayColor)
                    .padding(.leading, type.id == 2 ? 6 : 0)
                Text(type.name)
                    .font(.custom("NanumSquareOTFB", size: 10))
                    .foregroundColor(viewModel.selectedPage == type.id ? orangeColor : lightGrayColor)
            }
        }
    }
    
    var dayPageTab: some View {
        HStack(alignment: .top) {
            
            Button(action: {
                viewModel.selectedDate = viewModel.prevDate
            }, label: {
                Image("PrevDate")
                    .resizable()
                    .frame(width: 10, height: 16)
            })
            .padding(.leading, 16)
            
            Spacer()
            
            
            Text(viewModel.selectedFormatted)
                .font(.custom("NanumSquareOTFB", size: 15))
                .foregroundColor(orangeColor)
                .padding(.bottom, 10)
            
            Spacer()
            
            Button(action: {
                viewModel.selectedDate = viewModel.nextDate
            }, label: {
                Image("NextDate")
                    .resizable()
                    .frame(width: 10, height: 16)
            })
            .padding(.trailing, 16)
            
            
//            Button(action: {
//                viewModel.selectedDate = viewModel.prevDate
//            }, label: {
//                Text(viewModel.prevFormatted)
//            })
//            .font(.custom("NanumSquareOTFR", size: 14))
//            .foregroundColor(lightGrayColor)
//
//            Spacer()
//
//            VStack(spacing: 0) {
//                Text(viewModel.selectedFormatted)
//                    .font(.custom("NanumSquareOTFB", size: 15))
//                    .foregroundColor(orangeColor)
//                    .padding(.bottom, 10)
//
//                orangeColor
//                    .frame(width: 150, height: 2)
//            }
//
//            Spacer()
//
//            Button(action: {
//                viewModel.selectedDate = viewModel.nextDate
//            }, label: {
//                Text(viewModel.nextFormatted)
//            })
//            .font(.custom("NanumSquareOTFR", size: 14))
//            .foregroundColor(lightGrayColor)

        }
        .padding(EdgeInsets(top: 20, leading: 0, bottom: 16, trailing: 0))
        .background(Color.white.shadow(color: .init(white: 0.9), radius: 2, x: 0, y: 3.5))
    }
    
    var menuList: some View {
        // Menus
        VStack(alignment: .center) {
            if !viewModel.noMenu {
                ZStack {
                    
                    HStack(alignment: .bottom, spacing: 30) {
                        Spacer()
                        ForEach(typeInfos) { type in
                            typeButton(type: type)
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                    
                    
                    Button(action: {
                        withAnimation {
//                            appState.monthToShow = viewModel.selectedDate
                        }
                    }, label: {
                        Image("CalendarSettings")
                            .resizable()
                            .frame(width: 19.5, height: 16)
                            .padding(.leading, UIScreen.main.bounds.width - 46)
                    })
                    .padding(.top, 8)

                }
                
                PageView(currentPage: $viewModel.selectedPage, viewModel.restaurantsLists.map { RestaurantsView($0) })
                
            } else {
                VStack {
                    Spacer()
                    Text("불러온 식단이 없습니다")
                        .font(.custom("NanumSquareOTFB", size: 15))
                        .foregroundColor(fontColor)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
                .background(Color.init("AppBackgroundColor"))
            }
        }
        .background(Color.init("AppBackgroundColor"))
        .padding(.top, -4)
    }
}

// MARK: - Menu View

struct MenuView: View {
    @ObservedObject var viewModel = MenuViewModel()
    @EnvironmentObject var appState: AppState
    
    private let lightGrayColor = Color.init("LightGrayColor")
    private let orangeColor = Color.init("MainThemeColor")
    private let fontColor = Color("DefaultFontColor")
    
    var typeInfos: [TypeInfo] = [
        TypeInfo(type: .breakfast),
        TypeInfo(type: .lunch),
        TypeInfo(type: .dinner)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    NavigationBar(geometry)
                    
                    dayPageTab
                    
                    menuList
                }
                .blur(radius: viewModel.getMenuStatus == .loading ? 5 : 0)
                .disabled(viewModel.getMenuStatus == .loading)
                
                if viewModel.getMenuStatus == .loading {
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                }
            }
            .alert(isPresented: $viewModel.showNetworkAlert, content: {
                Alert(title: Text("식단"), message: Text("식단을 받아오지 못했습니다. 이전에 불러왔던 식단으로 대신 표시합니다."), dismissButton: .default(Text("확인")))
            })
            .onAppear {
                viewModel.firstShow = false
                viewModel.getMenu(date: viewModel.selectedDate)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                viewModel.getMenu(date: viewModel.selectedDate)
            }
        }
    }
}

// MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
