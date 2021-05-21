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
        HStack(alignment: .center) {
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
            
            Spacer()
            
            Button(action: {
                viewModel.selectedDate = viewModel.nextDate
            }, label: {
                Image("NextDate")
                    .resizable()
                    .frame(width: 10, height: 16)
            })
            .padding(.trailing, 16)
        }
        .padding(EdgeInsets(top: 12, leading: 0, bottom: 12, trailing: 0))
    }
    
    var menuList: some View {
        // Menus
        VStack(alignment: .center) {
            if viewModel.getMenuStatus == .loading {
                Spacer()
                HStack {
                    Spacer()
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                    Spacer()
                }
                Spacer()
            } else {
                if viewModel.restaurantsLists.count > 0 {
                    HStack(alignment: .bottom, spacing: 30) {
                        Spacer()
                        ForEach(typeInfos) { type in
                            typeButton(type: type)
                        }
                        Spacer()
                    }
                    .padding(.top, 8)
                    
                    PageView(currentPage: $viewModel.selectedPage, viewModel.restaurantsLists.map { RestaurantsView($0).environment(\.favoriteViewModel, viewModel) })
                    
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
        .padding(.top, -4)
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
            NavigationView {
                VStack {
                    NavigationBar(geometry)
                    if viewModel.noFavorites {
                        Spacer()
                        Text("즐겨찾기에 추가된 식당이 없습니다.\n식당 탭에서 별을 눌러 추가해보세요.")
                            .font(.custom("NanumSquareOTFB", size: 14))
                            .foregroundColor(lightGrayColor)
                        Spacer()
                    } else {
                        dayPageTab
                        
                        menuList
                    }
                }
                .navigationBarHidden(true)
                .disabled(viewModel.getMenuStatus == .loading)
            }
            .alert(isPresented: $viewModel.showNetworkAlert, content: {
                Alert(title: Text("식단"), message: Text("식단을 받아오지 못했습니다. 이전에 불러왔던 식단으로 대신 표시합니다."), dismissButton: .default(Text("확인")))
            })
            .onAppear {
                viewModel.getMenu(date: viewModel.selectedDate)
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
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
