//
//  RestaurantCell.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/03.
//

import SwiftUI

// MARK: - Restaurant Cell

struct RestaurantCell: View {
    private let lightGrayColor = Color.gray600
    private let orangeColor = Color.orange500
    
    let item: RestaurantMenusDisplayModel
    let selectedPage:Int
    let dayType:Int
    let onFavoriteTap: (Int) -> Void
    @State var showRestaurant: Bool = false
    @StateObject private var kakaoShareManager = KakaoShareManager()
    @Environment(\.menuViewModel) var viewModel: MenuViewModel?
    
    init(item: RestaurantMenusDisplayModel, selectedPage:Int, dayType:Int, onFavoriteTap: @escaping (Int) -> Void) {
        self.item = item
        self.selectedPage = selectedPage
        self.dayType = dayType
        self.onFavoriteTap = onFavoriteTap
    }
    
    var body: some View {
        let restaurant = item.restaurantObject
        let meals = item.menus.map { $0.mealObject }
        
        VStack(spacing: 0) {
            // Restaurant Name
            HStack(alignment: .center) {
                Text(item.nameKr)
                    .customFont(font: .text16(weight: .ExtraBold))
                    .foregroundColor(.blackColor)
                Spacer()
                    .frame(width:6)
                Button(action: {
                    self.showRestaurant = true
                }) {
                    Image(.Icons.Common.information)
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
                    onFavoriteTap(item.restaurantId)
                }, label: {
                    Image(item.isFavorite ? "Favorite-selected" : "Favorite-default")
                        .resizable()
                        .renderingMode(.original)
                        .frame(width: 20, height: 20)
                })
                Spacer()
                    .frame(width:4)
                Button(action: {
                    kakaoShareManager.shareKakao(restaurant: restaurant, selectedDateString: viewModel?.selectedDate ?? "오늘")
                
                }) {
                    Image(.Icons.Common.share)
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
                Image(TypeInfo(type:TypeSelection(rawValue: (selectedPage))!).icon)
                    .resizable()
                    .renderingMode(.template)
                    .frame(width: 16, height: 16)
                    .foregroundColor(Color.gray600)
                Spacer()
                    .frame(width:4)
                Text(MenuViewModel.getOperatingHours(operatingHours: item.operatingHours, dayType: dayType, selectedPage: selectedPage))
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
        .background(Color.backgroundSecondary)
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.gray200, lineWidth: 1)
        )
    }
}

// MARK: - Preview

struct RestaurantCell_Previews: PreviewProvider {
    
    static var previews: some View {
        let displayModel = RestaurantMenusDisplayModel(
            id: "0-1",
            restaurantId: 1,
            code: "SH",
            nameKr: "학생회관",
            nameEn: "Student Hall",
            address: "학생회관 1층",
            coordinate: Coordinate(latitude: 37.123, longitude: 127.123),
            operatingHours: [
                "08:00 - 09:00\n11:30 - 13:30\n17:30 - 19:00",
                "09:00 - 13:00\n17:00 - 18:30",
                "Closed"
            ],
            menus: [
                MenuItemDisplayModel(
                    id: 101,
                    code: "A",
                    nameKr: "김치찌개",
                    nameEn: "Kimchi Stew",
                    price: 4500,
                    score: 4.2,
                    reviewCount: 20,
                    isLiked: true,
                    likeCount: 10,
                    imageURLStrings: []
                ),
                MenuItemDisplayModel(
                    id: 102,
                    code: "B",
                    nameKr: "제육볶음",
                    nameEn: "Spicy Pork",
                    price: 5000,
                    score: 4.5,
                    reviewCount: 35,
                    isLiked: false,
                    likeCount: 22,
                    imageURLStrings: []
                )
            ],
            isFavorite: true
        )
        
        return RestaurantCell(item: displayModel, selectedPage: 0, dayType: 0, onFavoriteTap: { _ in })
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

private extension RestaurantMenusDisplayModel {
    var restaurantObject: Restaurant {
        Restaurant(
            id: restaurantId,
            code: code,
            nameKr: nameKr,
            nameEn: nameEn,
            addr: address,
            lat: coordinate.map { String($0.latitude) } ?? "",
            lng: coordinate.map { String($0.longitude) } ?? "",
            operatingHours: operatingHours,
            menus: menus.map { $0.mealObject }
        )
    }
}

private extension MenuItemDisplayModel {
    var mealObject: Meal {
        Meal(
            id: id,
            code: code,
            nameKr: nameKr,
            nameEn: nameEn,
            price: price,
            score: score,
            reviewCnt: reviewCount,
            isLiked: isLiked,
            likeCnt: likeCount,
            etc: imageURLStrings
        )
    }
}
