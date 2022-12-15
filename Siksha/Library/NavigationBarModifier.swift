//
//  NavigationBarModifier.swift
//  Siksha
//
//  Created by 박종석 on 2021/06/12.
//

import Foundation
import SwiftUI

struct NavigationBarModifier: ViewModifier {
    var title: String
    
    init(title: String) {
        self.title = title
        
        let coloredAppearance = UINavigationBarAppearance()
        
        if #available(iOS 16, *) {
            coloredAppearance.backgroundColor = .clear
        }
        else {
            coloredAppearance.backgroundColor = UIColor(named: "MainThemeColor")
        }

        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
    }
    
    func body(content: Content) -> some View {
        let mainContentView = content
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if title == "icon" {
                        Image("SikshaTitle")
                            .resizable()
                            .frame(width: 52, height: 42)
                            .padding(.bottom, -4)
                    } else {
                        Text(title)
                            .foregroundColor(.white)
                            .font(.custom("NanumSquareOTFEB", size: 18))
                    }
                }
                
            }
            .navigationViewStyle(StackNavigationViewStyle())
        
        if #available(iOS 16, *) {
            ZStack {
                mainContentView
                VStack {
                    GeometryReader { geometry in
                        Color("MainThemeColor")
                            .frame(height: geometry.safeAreaInsets.top)
                            .edgesIgnoringSafeArea(.top)
                        Spacer()
                    }
                }
            }
        }
        else {
            mainContentView
        }
    }
}
