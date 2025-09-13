//
//  LikedMenuRestaurantCell.swift
//  Siksha
//
//  Created by 박정헌 on 8/17/25.
//


import SwiftUI


struct LikedMenuRestaurantCell: View {
    private let lightGrayColor = Color.gray600
    private let orangeColor = Color.orange500
    
    var restaurant: Restaurant
    var meals: [Meal]
    @State var isFavorite: Bool = false
    @State var showRestaurant: Bool = false
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
                    .customFont(font: .text16(weight: .ExtraBold))
                    .foregroundColor(.blackColor)
                Spacer()
                    .frame(width:6)
                Button(action: {
                    isFavorite.toggle()
                    UserDefaults.standard.set(isFavorite, forKey: "fav\(restaurant.id)")
                    if viewModel?.isFavoriteTab == true {
                        viewModel?.getMenuStatus = .needRerender
                    }
                }, label: {
                    Image(isFavorite ? "Favorite-selected" : "Favorite-default")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 20, height: 20)
                })
                Spacer()
                Text("Price")
                    .customFont(font: .text12(weight: .Regular))
                    .multilineTextAlignment(.center)
                    .frame(width:28)
                    .foregroundColor(orangeColor)
                Spacer()
                    .frame(width:16)
                Text("Rate")
                    .customFont(font: .text12(weight: .Regular))
                    .multilineTextAlignment(.center)
                    .frame(width:26)
                    .foregroundColor(orangeColor)
                Spacer()
                    .frame(width:16)
                Text("Like")
                    .customFont(font: .text12(weight: .Regular))
                    .multilineTextAlignment(.center)
                    .foregroundColor(orangeColor)
                    .frame(width:25)

      
            }
            .padding(EdgeInsets(top: 13, leading: 13,bottom: 6.5,trailing: 13))
     

       
            Capsule()
                .frame(height:1.5)
                .foregroundColor(orangeColor)
                .padding([.trailing], 11.5)
                .padding([.leading],11.5)
            VStack(spacing: 13) {
                    ForEach(meals, id: \.id) { meal in
                        let mealInfoViewModel = MealInfoViewModel(meal: meal)
                        NavigationLink(
                            destination: MealInfoView(viewModel: mealInfoViewModel)
                                .environment(\.menuViewModel, viewModel)
                                .onAppear {
                                    viewModel?.reloadOnAppear = false
                                },
                            label: {
                                MealCell(viewModel: mealInfoViewModel)
                                    .id("\(meal.id)\(meal.score)")
                            })
                    }
                
            }
            .padding(EdgeInsets(top: 13, leading: 13, bottom: 17, trailing: 13))
        }
        .padding(.zero)
        .background(Color.backgroundSecondary)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray200, lineWidth: 1)
        )
    }
}

// MARK: - Preview

struct LikedMenuRestaurantCell_Previews: PreviewProvider {
    
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

        return LikedMenuRestaurantCell(nonEmptyRes)
    }
}
