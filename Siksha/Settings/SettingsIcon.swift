//
//  SettingsIcon.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/09.
//

import SwiftUI

struct SettingsIcon: View {
    var imageName: String
    var rotationAnimation: Bool
    var noMenuHide: Bool
    
    var animation: Animation {
        Animation.easeIn
            .repeatForever(autoreverses: false)
    }
    
    var body: some View {
        if (noMenuHide) {
            Image("Checked")
                .resizable()
                .frame(width: 15, height: 15)
        } else if (rotationAnimation) {
            Image(imageName)
                .resizable()
                .frame(width: 15, height: 15)
                .rotationEffect(.degrees(rotationAnimation ? 360 : 0))
                .animation(rotationAnimation ? animation: nil)
        } else {
            Image(imageName)
                .resizable()
                .frame(width: 15, height: 15)
        }
        
    }
}

struct SettingsIcon_Previews: PreviewProvider {
    static var previews: some View {
        SettingsIcon(imageName: "NotChecked", rotationAnimation: false, noMenuHide: true)
    }
}
