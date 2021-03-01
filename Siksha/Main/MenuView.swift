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
            Image(type.icon)
                .renderingMode(.template)
                .resizable()
                .frame(width: type.width, height: type.height)
                .foregroundColor(viewModel.selectedPage == type.id ? orangeColor : lightGrayColor)
                .padding(.leading, type.id == 2 ? 6 : 0)
        }
    }
    
    var dayPageTab: some View {
        HStack(alignment: .top) {
            Button(action: {
                viewModel.selectedPage = 0
                viewModel.selectedDate = viewModel.prevDate
            }, label: {
                Text(viewModel.prevFormatted)
            })
            .frame(width: 80, alignment: .leading)
            .font(.custom("NanumSquareOTFR", size: 14))
            .foregroundColor(lightGrayColor)
            
            Spacer()
            
            VStack(spacing: 0) {
                Text(viewModel.selectedFormatted)
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(orangeColor)
                    .padding(.bottom, 10)
                    
                orangeColor
                    .frame(width: 150, height: 2)
            }
            
            Spacer()
            
            Button(action: {
                viewModel.selectedPage = 0
                viewModel.selectedDate = viewModel.nextDate
            }, label: {
                Text(viewModel.nextFormatted)
            })
            .frame(width: 80, alignment: .trailing)
            .font(.custom("NanumSquareOTFR", size: 14))
            .foregroundColor(lightGrayColor)
        }
        .padding(EdgeInsets(top: 2, leading: 25, bottom: 0, trailing: 25))
        .background(Color.white.shadow(color: .init(white: 0.9), radius: 2, x: 0, y: 3.5))
    }
    
    var menuList: some View {
        // Menus
        VStack(alignment: .center) {
            if !viewModel.noMenu {
                HStack(spacing: 30) {
                    ForEach(typeInfos) { type in
                        typeButton(type: type)
                    }
                }
                .padding(.top, 8)
                
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
                viewModel.getMenu(date: viewModel.selectedDate)
            }
        }
    }
}

// MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
            .environmentObject(AppState())
    }
}
