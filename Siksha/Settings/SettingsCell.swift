//
//  SettingsCell.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/13.
//
import SwiftUI

struct SettingsCell<Content: View>: View {
    var icon: Content
    var text: String
    
    init(text: String, @ViewBuilder _ icon: () -> Content) {
        self.text = text
        self.icon = icon()
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            Image("SettingsCell")
                .resizable()
                .renderingMode(.original)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
    
            HStack() {
                Text(text)
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(.init("DefaultFontColor"))
                      
                Spacer()
                
                icon
            }
            .padding([.leading, .trailing], 20)
        }
    }
}

struct SettingsCell_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCell(text: "식샤 정보") {
            Image("Arrow")
        }
    }
}
