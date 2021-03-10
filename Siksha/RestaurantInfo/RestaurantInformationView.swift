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
    
    let position: NMGLatLng
        
    init(_ restaurant: Restaurant) {
        self.restaurant = restaurant
        self.position = NMGLatLng(lat: Double(restaurant.lat)!, lng: Double(restaurant.lng)!)
    }

    var body: some View {
                
        VStack(spacing: 0) {
            
            HStack {
                Text(restaurant.addr)
                    .font(.custom("NanumSquareOTFR", size: 14))
                    .foregroundColor(Color("DefaultFontColor"))
                Spacer()
            }
            .padding(EdgeInsets(top: 20, leading: 30, bottom: 0, trailing: 30))
            
            HStack {
                Text(restaurant.nameKr)
                    .font(.custom("NanumSquareOTFB", size: 24))
                    .foregroundColor(Color("DefaultFontColor"))
                Spacer()
            }
            .padding(EdgeInsets(top: 4, leading: 30, bottom: 8, trailing: 30))
            
            Color.init("MainThemeColor")
                .frame(height: 2)
                .padding([.leading, .trailing], 16)
            
            HStack {
                Text("식당 위치")
                    .font(.custom("NanumSquareOTFB", size: 16))
                    .foregroundColor(Color("DefaultFontColor"))
                
                Spacer()
            }
            .padding(EdgeInsets(top: 24, leading: 32, bottom: 0, trailing: 32))
            
            MapView(coordinate: position)
                .frame(height: 200)
                .cornerRadius(10)
                .padding(EdgeInsets(top: 4, leading: 28, bottom: 0, trailing: 28))

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
            .padding(EdgeInsets(top: 20, leading: 32, bottom: 0, trailing: 32))
            
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
