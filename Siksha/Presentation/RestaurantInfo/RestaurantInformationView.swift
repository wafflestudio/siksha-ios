//
//  RestaurantInformationView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/21.
//

import NMapsMap
import SwiftUI

struct RestaurantInformationView: View {
    @Environment(\.dismiss) var dismiss
    var restaurant: RestaurantInformationDisplayModel

    let position: NMGLatLng?

    init(_ restaurant: RestaurantInformationDisplayModel) {
        self.restaurant = restaurant

        if let coordinate = restaurant.coordinate {
            self.position = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        } else {
            self.position = nil
        }
    }

    init(_ restaurant: Restaurant) {
        self.init(
            RestaurantInformationDisplayModel(
                id: restaurant.id,
                nameKr: restaurant.nameKr,
                address: restaurant.addr,
                coordinate: {
                    guard let latitude = Double(restaurant.lat),
                        let longitude = Double(restaurant.lng)
                    else {
                        return nil
                    }
                    return Coordinate(latitude: latitude, longitude: longitude)
                }(),
                operatingHours: Array(restaurant.operatingHours)
            )
        )
    }

    @State var selected = 0

    var body: some View {

        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                HStack {
                    Text(restaurant.nameKr)
                        .customFont(font: .text20(weight: .ExtraBold))
                        .foregroundColor(Color.gray900)
                }
                .padding(EdgeInsets(top: 23, leading: 0, bottom: 10.73, trailing: 0))

                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image("Close")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(Color.gray900)
                    }
                    .padding(EdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 17))
                }
            }

            if position != nil {
                Color.borderPrimary
                    .frame(height: 1)
                    .frame(maxWidth: .infinity)
            }

            ScrollView {
                VStack(spacing: 0) {
                    if let position = position {
                        HStack(spacing: 4) {
                            Image("Location")
                                .resizable()
                                .frame(width: 24, height: 24)

                            Text("식당 위치")
                                .customFont(font: .text16(weight: .Bold))
                                .foregroundColor(Color.blackColor)
                            Spacer()
                        }
                        .padding(EdgeInsets(top: 13, leading: 16, bottom: 8, trailing: 16))

                        MapView(coordinate: position, markerText: restaurant.address)
                            .cornerRadius(10.0)
                            .frame(height: 250)
                            .padding(EdgeInsets(top: 0, leading: 16, bottom: 31, trailing: 16))
                        Color.borderPrimary
                            .frame(height: 10)
                            .frame(maxWidth: .infinity)
                    }

                    HStack(alignment: .center, spacing: 0) {
                        Image("Schedule")
                            .resizable()
                            .frame(width: 24, height: 24)
                        Spacer()
                            .frame(width: 4)
                        Text("영업 시간")
                            .customFont(font: .text16(weight: .Bold))
                            .foregroundStyle(Color.blackColor)
                        Spacer()
                    }
                    .padding(EdgeInsets(top: 24, leading: 16, bottom: 8, trailing: 16))

                    Color.orange500
                        .frame(height: 1.4)
                        .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))

                    OperatingHoursTable(
                        hours: restaurant.operatingHours, isFestivalRestaurant: restaurant.nameKr.contains("[축제]"))
                }
            }
        }
        .padding(.bottom)
        .background(Color.backgroundSecondary)
    }
}

struct RestaurantInformationView_Previews: PreviewProvider {
    static var previews: some View {
        let rest = RestaurantInformationDisplayModel(
            id: 1,
            nameKr: "302동 식당",
            address: "서울대학교 302동",
            coordinate: Coordinate(latitude: 37.5666102, longitude: 126.9783881),
            operatingHours: [
                "11:30 - 13:30 \n17:30 - 19:30 ",
                "11:30 - 13:30",
                "",
            ]
        )

        return RestaurantInformationView(rest)
    }
}
