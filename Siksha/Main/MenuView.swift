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
                    .padding(.leading, type.id == 2 ? 3 : 0)
                    .padding(.bottom, type.id == 1 ? 0 : 2)
                Text(type.name)
                    .font(.custom(viewModel.selectedPage == type.id ? "NanumSquareOTFB" : "NanumSquareOTFR", size: 10))
                    .foregroundColor(viewModel.selectedPage == type.id ? orangeColor : lightGrayColor)
            }
        }
    }
    
    var dayPageTab: some View {
        HStack(alignment: .center) {
            Button(action: {
                viewModel.selectedDate = viewModel.prevDate
            }, label: {
                Image(viewModel.showCalendar ? "PrevDate-disabled" : "PrevDate")
                    .resizable()
                    .frame(width: 10, height: 16)
            })
            .disabled(viewModel.showCalendar)
            .padding(.leading, 16)
            
            Spacer()
            
            Button(action: {
                viewModel.showCalendar.toggle()
            }, label: {
                Text(viewModel.selectedFormatted)
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(orangeColor)
            })
            
            Spacer()
            
            Button(action: {
                viewModel.selectedDate = viewModel.nextDate
            }, label: {
                Image(viewModel.showCalendar ? "NextDate-disabled" : "NextDate")
                    .resizable()
                    .frame(width: 10, height: 16)
            })
            .disabled(viewModel.showCalendar)
            .padding(.trailing, 16)
        }
        .frame(height: 40)
    }
    
    var menuList: some View {
        // Menus
        VStack(alignment: .center) {
            if viewModel.getMenuStatus == .loading {
                VStack {
                    Spacer()
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                if viewModel.restaurantsLists.count > 0 {
                    HStack(alignment: .bottom, spacing: 28) {
                        Spacer()
                        ForEach(typeInfos) { type in
                            typeButton(type: type)
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                    
                    PageView(
                        currentPage: $viewModel.selectedPage,
                        needReload: $viewModel.pageViewReload,
                        viewModel.restaurantsLists.map { RestaurantsView($0).environment(\.menuViewModel, viewModel) })
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
        }
        .background(Color.init("AppBackgroundColor"))
    }
}

// MARK: - Menu View

struct MenuView: View {
    @ObservedObject var viewModel = MenuViewModel()
    
    private let lightGrayColor = Color.init("LightGrayColor")
    private let orangeColor = Color.init("MainThemeColor")
    private let fontColor = Color("DefaultFontColor")
    
    var typeInfos: [TypeInfo] = [
        TypeInfo(type: .breakfast),
        TypeInfo(type: .lunch),
        TypeInfo(type: .dinner)
    ]
    
    var body: some View {
            VStack {
                NavigationBar()
                
                dayPageTab
                    .frame(height: 40)
                
                ZStack(alignment: .top) {
                    menuList
                    
                    if viewModel.showCalendar {
                        Color.init(.sRGB, white: 0, opacity: 0.6)
                            .onTapGesture {
                                viewModel.showCalendar = false
                            }
                            .transition(.opacity.animation(.easeInOut))
                            .zIndex(1)
                        
                        CalendarView(selectedDate: $viewModel.selectedDate)
                            .frame(height: 300)
                            .padding(EdgeInsets(top: 4, leading: 10, bottom: 15, trailing: 10))
                            .background(Color.white)
                            .transition(.opacity.animation(.easeInOut))
                            .zIndex(2)
                    }
                }
                .padding(.top, -4)
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .alert(isPresented: $viewModel.showNetworkAlert, content: {
                Alert(title: Text("식단"), message: Text("식단을 받아오지 못했습니다. 이전에 불러왔던 식단으로 대신 표시합니다."), dismissButton: .default(Text("확인")))
            })
            .onAppear {
                if viewModel.reloadOnAppear {
                    viewModel.getMenu(date: viewModel.selectedDate)
                } else {
                    viewModel.reloadOnAppear = true
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                viewModel.getMenu(date: viewModel.selectedDate)
            }
    }
}

// MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
