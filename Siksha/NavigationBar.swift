//
//  NavigationBar.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI

struct NavigationBar: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Image("NaviBar")
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top+40)
                    .padding(.top, -geometry.safeAreaInsets.top)
                
                Image("Logo")
            }
        }
    }
}

struct NavigationBar_Previews: PreviewProvider {
    static var previews: some View {
        NavigationBar()
    }
}
