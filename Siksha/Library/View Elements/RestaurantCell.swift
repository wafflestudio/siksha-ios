//
//  RestaurantCell.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/03.
//

import SwiftUI

// MARK: - Restaurant Cell

struct RestaurantCell: View {
    private let fontColor = Color("DefaultFontColor")
    private let titleColor = Color("TitleFontColor")
    private let lightGrayColor = Color("LightGrayColor")
    private let orangeColor = Color.init("main")
    
    var restaurant: Restaurant
    var meals: [Meal]
    @State var isFavorite: Bool = false
    @State var showRestaurant: Bool = false
    @Environment(\.favoriteViewModel) var favViewModel: FavoriteViewModel?
    @Environment(\.menuViewModel) var viewModel: MenuViewModel?
    
    init(_ restaurant: Restaurant) {
        self.restaurant = restaurant
        self.meals = Array(restaurant.menus)
        self._isFavorite = State(initialValue: UserDefaults.standard.bool(forKey: "fav\(restaurant.id)"))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Restaurant Name
            HStack(alignment: .center) {
                Text(restaurant.nameKr)
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(orangeColor)
                
                Button(action: {
                    self.showRestaurant = true
                }) {
                    Image("Info")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 17, height: 17)
                }
                .sheet(isPresented: $showRestaurant, content: {
                    RestaurantInformationView(restaurant)
                })
                
                Button(action: {
                    isFavorite.toggle()
                    UserDefaults.standard.set(isFavorite, forKey: "fav\(restaurant.id)")
                    favViewModel?.getMenuStatus = .needRerender
                }, label: {
                    Image(isFavorite ? "Favorite-selected" : "Favorite-default")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 18, height: 17)
                })
                
                Button(action: {
                    let kakaoManager = KakaoShareManager(restaurant)
                    kakaoManager.shareToKakao(restaurant: restaurant)
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 17, height: 17)
                        .foregroundColor(orangeColor)
                }
                
                Spacer()
                
                Text("Price")
                    .font(.custom("NanumSquareOTF", size: 12))
                    .foregroundColor(orangeColor)
                    .frame(width: 50)
                
                Text("Rate")
                    .font(.custom("NanumSquareOTF", size: 12))
                    .foregroundColor(orangeColor)
                    .frame(width: 35)
                
                Text("Like")
                    .font(.custom("NanumSquareOTF", size: 12))
                    .foregroundColor(orangeColor)
                    .frame(width: 35)
            }
            .padding(EdgeInsets(top: 16, leading: 16, bottom: 10, trailing: 16))
            
            HStack {
                orangeColor
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
            }
            .padding([.leading, .trailing], 12)
            
            
            VStack(spacing: 20) {
                if meals.count > 0 {
                    ForEach(meals, id: \.id) { meal in
                        let mealInfoViewModel = MealInfoViewModel(meal: meal)
                        NavigationLink(
                            destination: MealInfoView(viewModel: mealInfoViewModel)
                                .environment(\.menuViewModel, viewModel)
                                .environment(\.favoriteViewModel, favViewModel)
                                .onAppear{
                                    favViewModel?.reloadOnAppear = false
                                    viewModel?.reloadOnAppear = false
                                },
                            label: {
                                MealCell(viewModel: mealInfoViewModel)
                                    .id("\(meal.id)\(meal.score)")
                            })
                    }
                } else {
                    HStack(alignment: .center) {
                        Text("해당 시간대의 메뉴가 없습니다.")
                            .font(.custom("NanumSquareOTFR", size: 14))
                            .foregroundColor(lightGrayColor)
                    }
                    .padding([.top, .bottom], 12)
                }
            }
            .padding(EdgeInsets(top: 14, leading: 16, bottom: 16, trailing: 16))
        }
        .background(Color.white)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.init(white: 232/255), lineWidth: 1)
        )
    }
}

// MARK: - Preview

struct RestaurantCell_Previews: PreviewProvider {
    
    static var previews: some View {
        let emptyRes = Restaurant()
        let nonEmptyRes = Restaurant()
        emptyRes.nameKr = "빈 식당"
        nonEmptyRes.nameKr = "든 식당"
        let menu = Meal()
        menu.price = 3000
        menu.nameKr = "식단"
        menu.reviewCnt = 1
        menu.score = 3
        let menu2 = Meal()
        menu2.price = 4000
        menu2.nameKr = "식단2"
        menu2.reviewCnt = 0
        menu2.score = 4
        nonEmptyRes.menus.append(menu)
        nonEmptyRes.menus.append(menu2)

        return RestaurantCell(nonEmptyRes)
    }
}
