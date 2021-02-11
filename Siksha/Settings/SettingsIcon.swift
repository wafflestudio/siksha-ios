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
    
    var image: String {
        if noMenuHide {
            return "Checked"
        } else {
            return imageName
        }
    }
        
    var body: some View {
        Image(image)
            .resizable()
            .frame(width: 15, height: 15)
            .rotationEffect(.degrees(rotationAnimation ? 360 : 0))
            .animation(rotationAnimation ? animation : nil)
    }
}

struct SettingsIcon_Previews: PreviewProvider {
    static var previews: some View {
        SettingsIcon(imageName: "NotChecked", rotationAnimation: false, noMenuHide: true)
    }
}
