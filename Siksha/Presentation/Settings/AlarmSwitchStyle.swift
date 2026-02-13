//
//  AlarmSwitchStyle.swift
//  Siksha
//
//  Created by 박정헌 on 8/30/25.
//

//
//  FestivalSwitchStyle.swift
//  Siksha
//
//  Created by 이지현 on 3/16/25.
//

import SwiftUI

struct AlarmSwitchStyle: ToggleStyle {
    private let onColor = LinearGradient(colors: [Color.orange500, Color(hex: 0xFF9DA4)], startPoint: .leading, endPoint: .trailing)
    private let offColor = LinearGradient(colors: [Color.iconGrayIcon], startPoint: .leading, endPoint: .trailing)
    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: 59.14)
            .fill(configuration.isOn ? onColor : offColor)
            .frame(width:36, height:22)
            .overlay(
                Circle()
                    .fill(Color.white)
                    .frame(width: 18, height: 18)
                    .shadow(color: Color.black.opacity(0.06), radius: 0.64, x: 0, y: 1.93)
                    .shadow(color: Color.black.opacity(0.15), radius: 5.15, x: 0, y: 1.93)
           
                    .offset(x: configuration.isOn ? 16 : 2)
                , alignment: .leading
            )
        
      
    }
}

struct AlarmSwitchStylePreviewWrapper: View {
    @State private var isOn = false
    
    var body: some View {
        Toggle(isOn: $isOn) {
            EmptyView()
        }
        .toggleStyle(AlarmSwitchStyle())
        .padding()
        .previewLayout(.sizeThatFits)
    
    }
}

struct AlarmSwitchStyle_Previews: PreviewProvider {
    static var previews: some View {
        AlarmSwitchStylePreviewWrapper()
    }
}
