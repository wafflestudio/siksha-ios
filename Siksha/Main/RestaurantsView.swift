//
//  RestaurantsView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/03.
//

import SwiftUI

struct RestaurantsView: View {
    private let fontColor = Color("DefaultFontColor")
    
    @EnvironmentObject var appState: AppState
    
    var day: DaySelection
    var type: TypeSelection
    
    init(_ day: DaySelection, _ type: TypeSelection) {
        self.day = day
        self.type = type
    }
    
    var restaurantsList: [Restaurant] {
        Array(appState.dailyMenus[day.rawValue].getRestaurants(type))
    }
    
    var body: some View {
        GeometryReader { geometry in
            if appState.dailyMenus.count > day.rawValue && restaurantsList.count > 0 {
                ScrollView(.vertical) {
                    ForEach(restaurantsList, id: \.id) { restaurant in
                        RestaurantCell(restaurant)
                            .padding([.leading, .trailing], 12)
                            .padding([.top, .bottom], 2)
                    }
                }
                .padding(.top, 2)
                .frame(width: geometry.size.width)
                .background(Color.init("AppBackgroundColor"))
            } else {
                Text("식단 정보가 없습니다")
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(fontColor)
            }
        }
    }
}

// MARK: - Preview

struct RestaurantsView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantsView(.today, .breakfast)
            .environmentObject(AppState())
    }
}
