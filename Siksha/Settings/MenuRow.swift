//
//  MenuRow.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/11.
//

import SwiftUI

struct MenuRow: View {
    var text: String
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image("OrderCell")
                .resizable()
                .frame(width: UIScreen.main.bounds.size.width - 20, height: 50)
            
            Text(text)
                .padding(.leading, 20)
                .font(.custom("NanumSquareOTFB", size: 15))
                .foregroundColor(.init("DefaultFontColor"))
        }
    }
}

struct MenuRow_Previews: PreviewProvider {
    static var previews: some View {
        MenuRow(text: "302동 식당")
    }
}
