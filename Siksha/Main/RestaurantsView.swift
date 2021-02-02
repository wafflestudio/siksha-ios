//
//  RestaurantsView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/03.
//

import SwiftUI

struct RestaurantsView: View {
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel = RestaurantsViewModel()
    
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
            VStack {
                Text("Restaurant List")
                if appState.dailyMenus.count > day.rawValue {
                    ForEach(restaurantsList, id: \.id) { _ in
                        HStack {
                        }
                    }
                } else {
                    Text("식단 정보가 없습니다")
                        .font(.custom("NanumSquareOTFB", size: 15))
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .background(Color.init("AppBackgroundColor"))
        }
    }
}

struct RestaurantsView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantsView(.today, .breakfast)
    }
}
