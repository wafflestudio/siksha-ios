//
//  FestivalSwitchStyle.swift
//  Siksha
//
//  Created by 이지현 on 3/16/25.
//

import SwiftUI

struct FestivalSwitchStyle: ToggleStyle {
    private let onColor = LinearGradient(colors: [Color("Orange500"), Color(hex: 0xFF9DA4)], startPoint: .leading, endPoint: .trailing)
    private let offColor = LinearGradient(colors: [Color("Gray500")], startPoint: .leading, endPoint: .trailing)
    
    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: 25)
            .fill(configuration.isOn ? onColor : offColor)
            .frame(width:50, height:24)
            .overlay(
                Circle()
                    .fill(Color.white)
                    .frame(width: 20, height: 20)
                    .shadow(color: Color.black.opacity(0.06), radius: 0.7, x: 0, y: 2.11)
                    .shadow(color: Color.black.opacity(0.15), radius: 5.61, x: 0, y: 2.11)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.04), lineWidth: 0.7)
                    )
                    .offset(x: configuration.isOn ? 28 : 2)
                , alignment: .leading
            )
            .overlay(
                Text("축제")
                    .foregroundColor(Color.white)
                    .font(.custom("NanumSquareOTFB", size: 10))
                    .offset(x: configuration.isOn ? 6 : 26, y:0)
                , alignment: .leading
            )
            .onTapGesture {
                withAnimation(.easeOut(duration: 0.3)) {
                    configuration.$isOn.wrappedValue.toggle()
                }
            }
    }
}

struct FestivalSwitchStylePreviewWrapper: View {
    @State private var isOn = false
    
    var body: some View {
        Toggle(isOn: $isOn) {
            EmptyView()
        }
        .toggleStyle(FestivalSwitchStyle())
        .padding()
        .previewLayout(.sizeThatFits)
    }
}

struct FestivalSwitchStyle_Previews: PreviewProvider {
    static var previews: some View {
        FestivalSwitchStylePreviewWrapper()
    }
}
