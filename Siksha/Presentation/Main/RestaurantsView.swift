//
//  RestaurantsView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/03.
//

import SwiftUI
import Combine

struct RestaurantsView: View {
    private let fontColor = Color.gray600
    
    var restaurantMenusList: [RestaurantMenusDisplayModel]
    var selectedPage:Int
    var dayType:Int
    var onFavoriteTap: (Int) -> Void
    @State private var restaurantForInfo: RestaurantMenusDisplayModel?
    @State private var restaurantForShare: RestaurantMenusDisplayModel?
    @StateObject private var kakaoShareManager = KakaoShareManager()
    @Environment(\.menuViewModel) private var viewModel: MenuViewModel?
    
    init(_ restaurantMenusList: [RestaurantMenusDisplayModel],_ selectedPage:Int,_ dayType:Int,onFavoriteTap: @escaping (Int) -> Void){
        self.restaurantMenusList = restaurantMenusList
        self.selectedPage = selectedPage
        self.dayType = dayType
        self.onFavoriteTap = onFavoriteTap
    }
    
    var body: some View {
        Group {
            if restaurantMenusList.count > 0 {
                ScrollView(.vertical) {
                    VStack(spacing: 18) {
                        ForEach(restaurantMenusList, id: \.id) { restaurantMenus in
                            RestaurantCell(
                                item: restaurantMenus,
                                selectedPage: selectedPage,
                                dayType: dayType,
                                onInfoTap: {
                                    restaurantForInfo = restaurantMenus
                                },
                                onShareTap: {
                                    restaurantForShare = restaurantMenus
                                    kakaoShareManager.shareKakao(
                                        restaurant: restaurantMenus.kakaoShareModel,
                                        selectedDateString: viewModel?.selectedDate ?? "오늘"
                                    )
                                },
                                onFavoriteTap: onFavoriteTap,
                                menuRow: { menu in
                                    let mealInfoViewModel = MealInfoViewModel(meal: menu)
                                    NavigationLink(
                                        destination: MealInfoView(viewModel: mealInfoViewModel)
                                            .environment(\.menuViewModel, viewModel)
                                            .onAppear {
                                                viewModel?.reloadOnAppear = false
                                            },
                                        label: {
                                            MealCell(viewModel: mealInfoViewModel)
                                        }
                                    )
                                }
                            )
                                .padding([.leading, .trailing], 8)
                        }
                    }
                    .padding(.vertical, 8)
                }
                .background(Color.backgroundMain)
            } else {
                VStack {
                    HStack{
                        Text("식단 정보가 없습니다")
                            .font(.custom("NanumSquareOTFB", size: 15))
                            .foregroundColor(fontColor)
                    }
                    .frame(maxHeight: .infinity)
                }
                .frame(maxWidth: .infinity)
                .background(Color.backgroundMain)
            }
        }
        .sheet(item: $restaurantForInfo) { restaurant in
            RestaurantInformationView(restaurant.informationModel)
        }
        .sheet(isPresented: $kakaoShareManager.showWebView) {
            if let urlString = kakaoShareManager.urlToLoad,
               let restaurant = restaurantForShare {
                KakaoShareWebView(
                    urlString: urlString,
                    showWebView: $kakaoShareManager.showWebView,
                    restaurant: restaurant.kakaoShareModel,
                    selectedDate: viewModel?.selectedDate ?? "오늘"
                )
            }
        }
        .interactiveDismissDisabled(false)
    }
}
