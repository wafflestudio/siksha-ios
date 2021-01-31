//
//  SettingsView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI

private extension SettingsView {
    func settingsCell(text: String, _ geometry: GeometryProxy) -> some View {
        ZStack(alignment: .leading) {
            Image("SettingsCell")
                .resizable()
                .frame(width: geometry.size.width-32, height: 54)
            Text(text)
                .padding(.leading, 20)
                .font(.custom("NanumSquareOTFB", size: 15))
                .foregroundColor(.init("DefaultFontColor"))
        }
    }
}

struct SettingsView: View {
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Navigation Bar
                ZStack {
                    Image("NaviBar")
                        .resizable()
                        .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top+40)
                        .padding(.top, -geometry.safeAreaInsets.top)
                    
                    Image("Logo")
                }
                // Navigation Bar
                
                NavigationView {
                    VStack(alignment: .trailing, spacing: 10) {
                        Button(action: {
                            
                        }) {
                            settingsCell(text: "식샤 정보", geometry)
                        }
                        Button(action: {
                            
                        }) {
                            settingsCell(text: "메뉴 새로고침", geometry)
                        }
                        Spacer()
                    }
                    .padding(.top)
                    .navigationBarHidden(true)
                }
            }
        }

    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
