//
//  FavoriteView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/06.
//

import SwiftUI

private extension FavoriteView {
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
}

// MARK: - Favorite View

struct FavoriteView: View {
    @ObservedObject var viewModel = FavoriteViewModel()
    
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
                    // Navigation Bar
                    ZStack {
                        Image("NaviBar")
                            .resizable()
                            .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top+55)
                            .padding(.top, -geometry.safeAreaInsets.top)
                        
                        Image("Logo")
                            .padding(.bottom, 5)
                    }
                    // Navigaiton Bar
                    
                    // Day Page Tab
                    HStack {
                        Button(action: {
                            viewModel.selectedDate = viewModel.prevDate
                            viewModel.selectedPage = 0
                        }, label: {
                            Text(viewModel.prevFormatted)
                        })
                        .font(.custom("NanumSquareOTFB", size: 15))
                        .foregroundColor(lightGrayColor)
                        
                        Spacer()
                        
                        Text(viewModel.selectedFormatted)
                            .font(.custom("NanumSquareOTFB", size: 15))
                            .foregroundColor(orangeColor)
                        
                        Spacer()
                        
                        Button(action: {
                            viewModel.selectedDate = viewModel.nextDate
                            viewModel.selectedPage = 0
                        }, label: {
                            Text(viewModel.nextFormatted)
                        })
                        .font(.custom("NanumSquareOTFB", size: 15))
                        .foregroundColor(lightGrayColor)
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.top, .bottom], 10)
                    .padding([.leading, .trailing], 25)
                    .background(Color.white.shadow(color: .init(white: 0.9), radius: 2, x: 0, y: 3.5))
                    
                    // Menus
                    VStack(alignment: .center) {
                        if viewModel.restaurantsLists.count > 0 {
                            HStack(spacing: 30) {
                                ForEach(typeInfos) { type in
                                    typeButton(type: type)
                                }
                            }
                            .padding(.top, 8)
                            
                            PageView(currentPage: $viewModel.selectedPage, viewModel.restaurantsLists.map { RestaurantsView($0, onlyFavorites: true) })
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

struct FavoriteView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteView()
    }
}
