//
//  AlarmRestaurantCell.swift
//  Siksha
//
//  Created by 박정헌 on 8/28/25.
//

import SwiftUI

struct AlarmRestaurantCell: View {
    var restaurantName:String
    var menus:[String]
    var body: some View {
        VStack(alignment:.leading,spacing:0){
            Text(restaurantName)
                .foregroundStyle(Color.blackColor)
                .customFont(font: .text16(weight: .ExtraBold))
            Spacer()
                .frame(height:8)
            Capsule()
                .frame(height:1.5)
                .foregroundColor(Color.orange500)
            Spacer()
                .frame(height:8)
            ForEach(menus,id:\.self){
                menu in
                HStack(alignment: .center){
                    Text(menu)
                        .foregroundStyle(Color.blackColor)
                        .customFont(font: .text15(weight: .Regular))
                    Spacer()
                    Image("alarm-unchecked")
                        .resizable()
                        .frame(width:20,height:20)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 0))
                

            }
        }.padding(EdgeInsets(top: 14, leading: 14, bottom: 2, trailing: 14))
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .strokeBorder(Color.gray200, lineWidth: 1)
                    .background(Color.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            )
    }
}

#Preview {
    AlarmRestaurantCell(restaurantName: "학생회관 식당", menus: ["콩나물밥 & 부추양념", "돌솥부대찌개"])
}
