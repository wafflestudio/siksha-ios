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
    
    let position: NMGLatLng?

    init(_ restaurant: Restaurant) {
        self.restaurant = restaurant
        
        if let lat = Double(restaurant.lat), let lng = Double(restaurant.lng) {
                    self.position = NMGLatLng(lat: lat, lng: lng)
                } else {
                    self.position = nil
                }
    }
    
    @State var selected = 0
    
    var body: some View {
                        
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Text(restaurant.nameKr)
                    .font(.custom("NanumSquareOTFB", size: 20))
                    .foregroundColor(.black)
                Spacer()
            }
            .padding(EdgeInsets(top: 14, leading: 16, bottom: 10, trailing: 16))

            if position != nil {
                Color.init("main")
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing], 16)
            }
            
            ScrollView {
                if let position = position {
                    HStack {
                        Text("식당 위치")
                            .font(.custom("NanumSquareOTFR", size: 14))
                            .foregroundColor(.black)
                        Spacer()
                        
                        Image("Location")
                            .resizable()
                            .frame(width: 16, height: 16)
                        Text(restaurant.addr)
                            .font(.custom("NanumSquareOTFR", size: 14))
                            .foregroundColor(Color("LightFontColor"))
                    }
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 12, trailing: 16))
                    
                    MapView(coordinate: position, markerText: restaurant.addr)
                        .cornerRadius(10.0)
                        .frame(height: 250)
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 24, trailing: 16))
                    Color.init("DarkBackgroundColor")
                        .frame(height: 10)
                        .frame(maxWidth: .infinity)
                }


                HStack(alignment: .center, spacing: 0) {
                    Text("영업 시간")
                        .font(.custom("NanumSquareOTFR", size: 14))
                    Spacer()
                }
                .padding(EdgeInsets(top: 24, leading: 16, bottom: 8, trailing: 16))
                
                Color.init("main")
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing], 16)
                
                OperatingHoursTable(hours: Array(restaurant.operatingHours))
                
                Spacer()
            }
        }
        .padding(.bottom)
    }
}

struct RestaurantInformationView_Previews: PreviewProvider {
    static var previews: some View {
        let rest = Restaurant()
        rest.nameKr = "302동 식당"
        rest.addr = "서울대학교 302동"
        rest.lat = "37.5666102"
        rest.lng = "126.9783881"
        rest.operatingHours.append("11:30 - 13:30 \n17:30 - 19:30 ")
        rest.operatingHours.append("11:30 - 13:30")
        rest.operatingHours.append("")
        
        return RestaurantInformationView(rest)
    }
}
