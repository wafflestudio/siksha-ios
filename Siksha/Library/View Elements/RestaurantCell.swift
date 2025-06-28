//
//  RestaurantCell.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/03.
//

import SwiftUI

// MARK: - Restaurant Cell

struct RestaurantCell: View {
    private let fontColor = Color("Gray700")
    private let lightGrayColor = Color("Gray600")
    private let orangeColor = Color.init("Orange500")
    
    var restaurant: Restaurant
    var meals: [Meal]
    @State var isFavorite: Bool = false
    @State var showRestaurant: Bool = false
    @StateObject private var kakaoShareManager = KakaoShareManager()
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
                    .foregroundColor(.black)
                Spacer()
                    .frame(width:6)
                Button(action: {
                    self.showRestaurant = true
                }) {
                    Image("Info")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 20, height: 20)
                }
                .sheet(isPresented: $showRestaurant, content: {
                    RestaurantInformationView(restaurant)
                })
                Spacer()
                    .frame(width:4)
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
                    .frame(width:4)
                Button(action: {
                    kakaoShareManager.shareKakao(restaurant: restaurant, selectedDateString: viewModel?.selectedDate ?? "오늘")
                
                }) {
                    Image(.kakaoShare)
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 20, height: 20)
                        .foregroundColor(orangeColor)
                }.sheet(isPresented: $kakaoShareManager.showWebView) {
                    if let urlString = kakaoShareManager.urlToLoad {
                        KakaoShareWebView(urlString: urlString, showWebView: $kakaoShareManager.showWebView, restaurant: restaurant, selectedDate: viewModel?.selectedDate ?? "오늘")
                    }
                }.interactiveDismissDisabled(false)
                Spacer()
                /*Spacer()
                
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
                    .frame(width: 35)*/
            }
            .padding(EdgeInsets(top: 17, leading: 13,bottom: 11.5,trailing: 0))
            HStack(alignment: .center){
                Image("Lunch")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 16, height: 16)
                Spacer()
                    .frame(width:4)
                Text("11:00 - 13:00")
                    .customFont(font: .text12(weight: .Bold))
                    .foregroundColor(lightGrayColor)
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

            }.padding([.leading,.trailing],13)
            .padding([.bottom],6.5)

            /*HStack {
                orangeColor
                    .frame(maxWidth:.infinity)
                    .overlay(RoundedRectangle(cornerRadius: 1.5).stroke(orangeColor,lineWidth:1.5 ))
            }*/
            Capsule()
                .frame(height:1.5)
                .foregroundColor(orangeColor)
                .padding([.trailing], 14.5)
                .padding([.leading],11.5)
            VStack(spacing: 13) {
                if meals.count > 0 {
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
                } else {
                    HStack(alignment: .center) {
                        Text("해당 시간대의 메뉴가 없습니다.")
                            .font(.custom("NanumSquareOTFR", size: 14))
                            .foregroundColor(lightGrayColor)
                    }
                    .padding([.top, .bottom], 12)
                }
            }
            .padding(EdgeInsets(top: 13, leading: 13, bottom: 17, trailing: 13))
        }
        .padding(.zero)
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
