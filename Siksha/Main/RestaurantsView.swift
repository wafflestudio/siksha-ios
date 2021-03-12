//
//  RestaurantsView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/03.
//

import SwiftUI
import Combine

struct RestaurantsView: View {
    private let fontColor = Color("DefaultFontColor")
    
    var restaurantsList: [Restaurant]
        
    init(_ restaurants: [Restaurant]){
        self.restaurantsList = restaurants
    }
    
    var body: some View {
        if restaurantsList.count > 0 {
            ScrollView(.vertical) {
                ForEach(restaurantsList, id: \.id) { restaurant in
                    RestaurantCell(restaurant)
                        .padding([.leading, .trailing], 10)
                        .padding([.top, .bottom], 4)
                }
            }
            .padding(.top, 2)
            .padding(.bottom, 4)
            .background(Color.init("AppBackgroundColor"))
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
                .background(Color.init("AppBackgroundColor"))
        }
    }
}
