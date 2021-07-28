//
//  MenuRow.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/11.
//
import SwiftUI

struct RestaurantOrderRow: View {
    var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color.white.cornerRadius(10).shadow(color: .init(white: 0.75), radius: 1, x: 0, y: 0)
            
            Text(text)
                .padding(.leading, 15)
                .font(.custom("NanumSquareOTFB", size: 15))
                .foregroundColor(.init("DefaultFontColor"))
        }
        .frame(width: UIScreen.main.bounds.size.width-24, height: 40)
    }
}

struct MenuRow_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantOrderRow(text: "302동 식당")
    }
}
