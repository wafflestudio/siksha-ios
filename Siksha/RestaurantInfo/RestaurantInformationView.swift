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
                    .customFont(font: .text20(weight: .ExtraBold))
                    .foregroundColor(Color("Color/Foundation/Gray/900"))
                Spacer()
            }
            .padding(EdgeInsets(top: 23, leading: 0, bottom: 10.73, trailing: 0))
            
            if position != nil {
                Color.init("Color/Foundation/Gray/200") //TODO: FIX COLOR
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
            }
            
            ScrollView {
                VStack(spacing: 0){
                    if let position = position {
                        HStack {
                            Image("Location")
                                .resizable()
                                .frame(width: 24, height: 24)
                            
                            Text("식당 위치")
                                .customFont(font: .text16(weight: .Bold))
                                .foregroundColor(.black)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 13, leading: 16, bottom: 8, trailing: 16))
                        
                        MapView(coordinate: position, markerText: restaurant.addr)
                            .cornerRadius(10.0)
                            .frame(height: 250)
                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 31, trailing: 16))
                        Color.init("Color/Foundation/Gray/200") // TODO: FIX COLOR
                            .frame(height: 10)
                            .frame(maxWidth: .infinity)
                    }
                    
                    
                    HStack(alignment: .center, spacing: 0) {
                        Image("Schedule")
                            .resizable()
                            .frame(width: 24,height: 24)
                        Spacer()
                            .frame(width:4)
                        Text("영업 시간")
                            .customFont(font: .text16(weight: .Bold))
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 24, leading: 16, bottom: 8, trailing: 16))
                    
                    Color.init("Color/Foundation/Orange/500")
                        .frame(height: 1)
                    
                    OperatingHoursTable(hours: Array(restaurant.operatingHours), isFestivalRestaurant: restaurant.nameKr.contains("[축제]"))
                }
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
