//
//  Filter.swift
//  Siksha
//
//  Created by 박정헌 on 1/12/25.
//
import SwiftUI

struct FilterItem: View {
    var text: String
    var isOn: Bool
    var isCheck: Bool
    var body:some View {
        HStack(spacing: 2) {
            if (isOn && isCheck) {
                Image("FilterCheck")
                    .resizable()
                    .frame(width: 16, height: 16)
            }
            if (isOn) {
                Text(text)
                    .font(.custom("NanumSquareOTFB", size: 13))
            } else {
                Text(text)
                    .font(.custom("NanumSquareOTF", size: 13))
            }
            if (!isCheck) {
                Image("select")
                    .resizable()
                    .frame(width: 16, height: 16)
            }
        }
        .frame(height: 18)
        .padding(EdgeInsets(top: 8, leading: 10, bottom: 8, trailing: 10))
        .background(isOn ? Color("MainActiveColor") : .white)
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .strokeBorder(isOn ? Color("MainThemeColor") : Color("Gray200"), lineWidth: 1)
        )
    }
}

/*struct Filter_Previews: PreviewProvider {
    static var previews: some View {
        FilterItem(text: "거리", isOn: true, isCheck: false)
    }
}*/
