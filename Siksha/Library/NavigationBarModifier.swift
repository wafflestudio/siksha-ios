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
    }
    
    func body(content: Content) -> some View {
        content
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if title == "icon" {
                        Image("sikshaSplash")
                            .resizable()
                            .frame(width: 39, height: 23)
                    } else {
                        Text(title)
                            .foregroundColor(.white)
                            .font(.custom("NanumSquareOTFEB", size: 16))
                    }
                }
            }
            .toolbarBackground(Color.orange500, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationViewStyle(StackNavigationViewStyle())
    }
}
