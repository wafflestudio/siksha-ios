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
            }
        }.padding(EdgeInsets(top: 9, leading: 10, bottom: 10, trailing: 9))
            .background(isOn ? Color("MainActiveColor") : .white)
            .cornerRadius(30)
            .overlay(
                RoundedRectangle(cornerRadius: 30)
                    .stroke(isOn ? Color("MainThemeColor") : Color("FilterUnselectedBorderColor"), lineWidth: 1)
            )
    }
}

/*struct Filter_Previews: PreviewProvider {
    static var previews: some View {
        FilterItem(text: "거리", isOn: true, isCheck: false)
    }
}*/
