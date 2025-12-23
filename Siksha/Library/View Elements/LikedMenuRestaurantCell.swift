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
    
    var restaurant: MyLikedRestaurant
    let viewModel: MyLikedMenuViewModel
    @State var isFavorite: Bool = false
    @State var showRestaurant: Bool = false
    
    init(_ viewModel: MyLikedMenuViewModel, _ restaurant: MyLikedRestaurant) {
        self.viewModel = viewModel
        self.restaurant = restaurant
        self._isFavorite = State(initialValue: UserDefaults.standard.bool(forKey: "fav\(restaurant.id)"))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Restaurant Name
            
            ViewThatFits{
                HStack(alignment: .center) {
                    Text(restaurant.name)
                        .customFont(font: .text16(weight: .ExtraBold))
                        .foregroundColor(.blackColor)
                        .lineLimit(1)
                    Spacer()
                        .frame(width:6)
                    Button(action: {
                        isFavorite.toggle()
                        UserDefaults.standard.set(isFavorite, forKey: "fav\(restaurant.id)")
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
                VStack(spacing:10){
                    HStack(alignment: .center) {
                        Text(restaurant.name)
                            .customFont(font: .text16(weight: .ExtraBold))
                            .foregroundColor(.blackColor)
                        Spacer()
                            .frame(width:6)
                        Button(action: {
                            isFavorite.toggle()
                            UserDefaults.standard.set(isFavorite, forKey: "fav\(restaurant.id)")
                        }, label: {
                            Image(isFavorite ? "Favorite-selected" : "Favorite-default")
                                .resizable()
                                .renderingMode(.original)
                                .frame(width: 20, height: 20)
                        })
                        
                        
                    }
                    HStack{
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

                }   .padding(EdgeInsets(top: 13, leading: 13,bottom: 6.5,trailing: 13))

            }
     

       
            Capsule()
                .frame(height:1.5)
                .foregroundColor(orangeColor)
                .padding([.trailing], 11.5)
                .padding([.leading],11.5)
            VStack(spacing: 13) {
                ForEach(restaurant.menus, id: \.id) { menu in
                    let mealInfoViewModel = MealInfoViewModel(meal: Meal.fromMyLikedMenu(menu: menu))
                 
                    MyLikedMenuMealCell(viewModel: viewModel, menu: menu)
                         
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

