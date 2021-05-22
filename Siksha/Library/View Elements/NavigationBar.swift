//
//  NavigationBar.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/05.
//

import SwiftUI

struct NavigationBar: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    var title: String
    var showBack: Bool
    var geometry: GeometryProxy
    
    init(title: String = "", showBack: Bool = false, _ geometry: GeometryProxy) {
        self.title = title
        self.showBack = showBack
        self.geometry = geometry
    }
    
    var body: some View {
        ZStack {
            Color.init("MainThemeColor")
                .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top+55)
                .padding(.top, -geometry.safeAreaInsets.top)
//            Image("Logo-new")
//                .padding(.bottom, 5)
            
            HStack {
                if showBack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image("NavigationBack")
                            .resizable()
                            .frame(width: 10, height: 16)
                    }
                }
                
                Spacer()
                
                if title == "" {
                    Image("SikshaTitle")
                        .resizable()
                        .frame(width: 42, height: 38)
                        .padding(.bottom, 0)
                } else {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.custom("NanumSquareOTFB", size: 18))
                }
                
                Spacer()
                
                Text("")
                    .frame(width:10, height: 16)
            }
            .padding([.leading, .trailing], 16)
        }
    }
}
