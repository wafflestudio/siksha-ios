//
//  FestivalSwitchStyle.swift
//  Siksha
//
//  Created by 이지현 on 3/16/25.
//

import SwiftUI

struct FestivalSwitchStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerSize: CGSize(width: 9.69, height: 9.69))
            .fill(configuration.isOn ? Color("MainThemeColor") : Color("ReviewLowColor"))
            .frame(width:45, height:19)
            .overlay(
                Circle()
                    .fill(Color.white)
                    .frame(width:17, height: 17, alignment: .leading)
                    .offset(x: configuration.isOn ? 26.19 : 1.6, y:0)
                , alignment: .leading
            )
            .overlay(
                Text("축제")
                    .foregroundColor(Color.white)
                    .font(.custom("NanumSquareOTFB", size: 9))
                    .offset(x: configuration.isOn ? 6.5 : 21.83, y:0)
                , alignment: .leading
            )
            .onTapGesture {
                withAnimation {
                    configuration.$isOn.wrappedValue.toggle()
                }
            }
    }
}
