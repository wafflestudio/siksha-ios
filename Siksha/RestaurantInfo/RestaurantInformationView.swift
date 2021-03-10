//
//  RestaurantInformationView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/21.
//

import SwiftUI
import NMapsMap

struct RestaurantInformationView: View {
    
    var restaurant: Restaurant
        
    init(_ restaurant: Restaurant) {
        self.restaurant = restaurant
    }
    
    @EnvironmentObject var appState: AppState

    var body: some View {
                
        VStack(spacing: 0) {
            
            HStack(alignment: .top, spacing: 11) {
                Text(restaurant.addr)
                    .font(.custom("NanumSquareOTFR", size: 14))
                    .foregroundColor(Color("DefaultFontColor"))
                Spacer()
            }
            .padding([.leading, .trailing], 14)
            .padding(.top, 12)
            
            HStack {
                Text(restaurant.nameKr)
                    .font(.custom("NanumSquareOTFB", size: 24))
                    .foregroundColor(Color("DefaultFontColor"))
                Spacer()
            }
            .padding([.leading, .trailing], 14)
            .padding(.top, 5)
            .padding([.bottom], 12)
            
            Color.init("MainThemeColor")
                .frame(height: 2)
                .frame(maxWidth: .infinity)
            
            HStack(alignment: .top, spacing: 11) {
                Text("식당 위치")
                    .font(.custom("NanumSquareOTFB", size: 16))
                    .foregroundColor(Color("DefaultFontColor"))
                
                Spacer()
            }
            .padding([.leading, .trailing], 16)
            .padding(.top, 20)
            
            let position = NMGLatLng(lat: Double(restaurant.lat)!, lng: Double(restaurant.lng)!)
            MapView(coordinate: position)
                .frame(height: 200)
                .padding([.top, .bottom])

            HStack(alignment: .top, spacing: 11) {
                Text("영업 시간")
                    .font(.custom("NanumSquareOTFB", size: 16))
                    .foregroundColor(Color("DefaultFontColor"))
                
                VStack(alignment: .leading) {
                    Text(restaurant.etc != "" ? restaurant.etc : "정보 없음")
                        .font(.custom("NanumSquareOTFR", size: 13))
                        .foregroundColor(Color("DefaultFontColor"))
                }
                Spacer()
            }
            .padding(16)
            
            Spacer()
        }
        .padding(.bottom)
    }
}

struct RestaurantInformationView_Previews: PreviewProvider {
    static var previews: some View {
        let rest = Restaurant()
        rest.nameKr = "302동 식당"
        rest.addr = "서울대학교 302동"
        rest.etc = "오전 11:30 ~ 오후 1:30\n오후 5:30 ~ 오후 7:30"
        rest.lat = "37.5666102"
        rest.lng = "126.9783881"
        return RestaurantInformationView(rest)
    }
}
