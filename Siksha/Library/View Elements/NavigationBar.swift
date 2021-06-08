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
    var topSafeArea: CGFloat
    
    init(title: String = "", showBack: Bool = false) {
        self.title = title
        self.showBack = showBack
        
        self.topSafeArea = UIApplication.shared.windows[0].safeAreaInsets.top
    }
    
    var body: some View {
        ZStack {
            Color.init("MainThemeColor")
            HStack {
                if showBack {
                    Button(action: {
                        self.presentationMode.wrappedValue.dismiss()
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
                        .frame(width: 52, height: 42)
                        .padding(.bottom, -4)
                } else {
                    Text(title)
                        .foregroundColor(.white)
                        .font(.custom("NanumSquareOTFB", size: 18))
                }
                
                Spacer()
                
                Text("")
                    .frame(width:10, height: 16)
            }
            .padding(EdgeInsets(top: 10 + topSafeArea, leading: 16, bottom: 0, trailing: 16))
        }
        .frame(maxWidth: .infinity)
        .frame(height: topSafeArea+55)
        .edgesIgnoringSafeArea(.all)
    }
}
