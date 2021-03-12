//
//  RestaurantInfoView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/05.
//

import SwiftUI

// MARK: - Restaurant Info View

struct RestaurantInfoView: View {
    struct MapButtonInfo {
        var icon: String
        var url: URL?
        var fallbackUrl: URL
        
        init(icon: String, url: URL?, fallbackUrl: URL) {
            self.icon = icon
            self.url = url
            self.fallbackUrl = fallbackUrl
        }
    }
    private let fontColor = Color("DefaultFontColor")
    private let orangeColor = Color.init("MainThemeColor")
    
    @EnvironmentObject var appState: AppState
    
    var restaurant: Restaurant
    
    let mapButtonInfos: [MapButtonInfo]
    
    init(_ restaurant: Restaurant) {
        self.restaurant = restaurant
        self.mapButtonInfos = [
            MapButtonInfo(
                icon: "Kakao",
                url: URL(string: "daummaps://look?&p=\(restaurant.lat),\(restaurant.lng)"),
                fallbackUrl: URL(string: "https://itunes.apple.com/kr/app/id304608425?mt=8")!),
            MapButtonInfo(
                icon: "Naver",
                url: URL(string: "navermaps://?menu=location&pinType=place&lat=\(restaurant.lat)&lng=\(restaurant.lng)"),
                fallbackUrl: URL(string: "https://itunes.apple.com/kr/app/id311867728?mt=8")!),
            MapButtonInfo(
                icon: "Google",
                url: URL(string: "comgooglemaps://?center=\(restaurant.lat),\(restaurant.lng)"),
                fallbackUrl: URL(string: "https://itunes.apple.com/kr/app/id585027354?mt=8")!)
        ]
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text(restaurant.nameKr)
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(fontColor)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        appState.showRestaurantInfo = false
                    }
                }) {
                    Image("Close")
                        .resizable()
                        .frame(width: 18, height: 18)
                }
            }
            .padding([.leading, .trailing], 14)
            .padding([.top, .bottom], 12)
            
            orangeColor
                .frame(height: 2)
                .frame(maxWidth: .infinity)
            
            HStack(alignment: .top, spacing: 11) {
                Text("식당 위치")
                    .font(.custom("NanumSquareOTFB", size: 13))
                    .foregroundColor(fontColor)
                
                VStack(alignment: .leading, spacing: 11) {
                    Text(restaurant.addr)
                        .font(.custom("NanumSquareOTFR", size: 13))
                        .foregroundColor(fontColor)
                    
                    HStack(spacing: 14) {
                        ForEach(mapButtonInfos, id: \.icon) { info in
                            Button(action: {
                                UIApplication.shared.open(info.url ?? info.fallbackUrl, options: [:], completionHandler: nil)
                            }, label: {
                                Image(info.icon)
                                    .resizable()
                                    .frame(width: 34, height: 34)
                            })
                        }
                    }
                }
                
                Spacer()
            }
            .padding([.leading, .trailing], 16)
            .padding(.top, 20)
            
            HStack(alignment: .top, spacing: 11) {
                Text("영업 시간")
                    .font(.custom("NanumSquareOTFB", size: 13))
                    .foregroundColor(fontColor)
                
                Spacer()
            }
            .padding(16)
            
            Spacer()
        }
        .padding(.bottom)
    }
}

// MARK: - Preview

struct RestaurantInfoView_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantInfoView(Restaurant())
    }
}
