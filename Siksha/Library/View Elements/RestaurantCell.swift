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
    private let orangeColor = Color.init("MainThemeColor")
    
    var restaurant: Restaurant
    var meals: [Meal]
    @State var isFavorite: Bool = false
    @EnvironmentObject var appState: AppState
    @Environment(\.favoriteViewModel) var viewModel: FavoriteViewModel?
    
    init(_ restaurant: Restaurant) {
        self.restaurant = restaurant
        self.meals = Array(restaurant.menus)
        self._isFavorite = State(initialValue: UserDefaults.standard.bool(forKey: "fav\(restaurant.id)"))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Restaurant Name
            HStack {
                Text(restaurant.nameKr)
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(titleColor)
                
                Button(action: {
                    withAnimation {
                        appState.restaurantToShow = restaurant
                    }
                }) {
                    Image("Info")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 14, height: 14)
                }
                
                Spacer()
                
                Button(action: {
                    isFavorite.toggle()
                    UserDefaults.standard.set(isFavorite, forKey: "fav\(restaurant.id)")
                    viewModel?.getMenuStatus = .idle
                }, label: {
                    Image(isFavorite ? "Favorite-selected" : "Favorite-default")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 20, height: 20)
                })
            }
            .padding([.leading, .trailing], 16)
            .padding([.top, .bottom], 10)
            
            HStack {
                orangeColor
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
            }
            .padding([.leading, .trailing], 12)
            
            
            VStack(spacing: 7) {
                if meals.count > 0 {
                    ForEach(meals, id: \.id) { meal in
                        MealCell(meal: meal)
                            .id("\(meal.id)\(meal.score)")
                            .onTapGesture {
                                withAnimation {
                                    appState.mealToShow = meal
                                }
                            }
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
            .padding([.leading, .trailing], 16)
            .padding([.top, .bottom], 12)
        }
        .background(Color.white.cornerRadius(10).shadow(color: .init(white: 0.8), radius: 3, x: 0, y: 0))
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
