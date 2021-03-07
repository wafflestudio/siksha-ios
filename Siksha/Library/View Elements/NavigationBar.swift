//
//  NavigationBar.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/05.
//

import SwiftUI

struct NavigationBar: View {
    var geometry: GeometryProxy
    
    init(_ geometry: GeometryProxy) {
        self.geometry = geometry
    }
    
    var body: some View {
        ZStack {
            Image("NaviBar")
                .resizable()
                .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top+55)
                .padding(.top, -geometry.safeAreaInsets.top)
            Image("Logo")
                .padding(.bottom, 5)
        }
    }
}
