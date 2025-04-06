//
//  RestaurantsView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/03.
//

import SwiftUI
import Combine

struct RestaurantsView: View {
    private let fontColor = Color("Gray600")
    
    var restaurantsList: [Restaurant]
        
    init(_ restaurants: [Restaurant]){
        self.restaurantsList = restaurants
    }
    
    var body: some View {
        if restaurantsList.count > 0 {
            ScrollView(.vertical) {
                VStack(spacing: 18) {
                    ForEach(restaurantsList, id: \.id) { restaurant in
                        RestaurantCell(restaurant)
                            .padding([.leading, .trailing], 8)
                    }
                }
                .padding(.vertical, 8)
            }
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
