//
//  RestaurantCell.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/03.
//

import SwiftUI

private extension RestaurantCell {
    func mealCell(meal: Meal) -> some View {
        HStack {
            ZStack {
                Image("PriceBox")
                    .resizable()
                    .frame(width: 52, height: 23)

                Text(String(format: "%d", meal.price))
                    .font(.custom("NanumSquareOTFR", size: 13))
                    .foregroundColor(.white)
            }

            Text("\(meal.nameKr)")
                .font(.custom("NanumSquareOTFL", size: 14))
                .foregroundColor(.black)

            Spacer()

            Text(meal.reviewCnt > 0 ? String(format: "%.1f", meal.score) : "-")
                .font(.custom("NanumSquareOTFR", size: 13))
                .foregroundColor(.black)
        }
        .background(Color.white)
    }
}

// MARK: - Restaurant Cell

struct RestaurantCell: View {
    private let fontColor = Color("DefaultFontColor")
    private let orangeColor = Color.init("MainThemeColor")
    
    var restaurant: Restaurant
    var meals: [Meal]
    @State var isFavorite: Bool = false
    @EnvironmentObject var appState: AppState
    
    init(_ restaurant: Restaurant) {
        self.restaurant = restaurant
        self.meals = Array(restaurant.menus)
        self.isFavorite = UserDefaults.standard.bool(forKey: "fav\(restaurant.id)")
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Restaurant Name
            HStack {
                Text(restaurant.nameKr)
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(fontColor)
                
                Button(action: {
                    withAnimation {
                        appState.restaurantToShow = restaurant
                    }
                }) {
                    Image("Info")
                        .resizable()
                        .frame(width: 14, height: 14)
                }
                
                Spacer()
                
                Button(action: {
                    isFavorite.toggle()
                    UserDefaults.standard.set(isFavorite, forKey: "fav\(restaurant.id)")
                }, label: {
                    Image(isFavorite ? "Favorite-selected" : "Favorite-default")
                        .resizable()
                        .frame(width: 22, height: 21)
                })
            }
            .padding([.leading, .trailing], 14)
            .padding([.top, .bottom], 10)
            
            orangeColor
                .frame(height: 2)
                .frame(maxWidth: .infinity)
            
            VStack(spacing: 8) {
                if meals.count > 0 {
                    ForEach(meals, id: \.id) { meal in
                        mealCell(meal: meal)
                            .onTapGesture {
                                withAnimation {
                                    appState.mealToReview = meal
                                }
                            }
                    }
                } else {
                    HStack {
                        Text("메뉴가 없습니다.")
                            .font(.custom("NanumSquareOTFL", size: 14))
                        
                        Spacer()
                    }
                }
            }
            .padding([.leading, .trailing], 13)
            .padding([.top, .bottom], 10)
        }
        .background(Color.white.shadow(color: .init(white: 0.8), radius: 3, x: 0, y: 0))
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
        nonEmptyRes.menus.append(menu)

        return RestaurantCell(nonEmptyRes)
    }
}
