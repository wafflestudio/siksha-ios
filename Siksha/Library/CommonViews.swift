//
//  CommonViews.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/13.
//

import SwiftUI

struct BackButton: View {
    var presentationMode: Binding<PresentationMode>
    
    init(_ presentationMode: Binding<PresentationMode>) {
        self.presentationMode = presentationMode
    }
    
    var body: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image("Back")
                    .resizable()
                    .frame(width: 13, height: 21)
                    .padding(.trailing, 5)
                
                Text("설정")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(.init("LightGrayColor"))
            }
        }
        .frame(width: 100, alignment: .leading)
    }
}

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
