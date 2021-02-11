//
//  VersionView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/05.
//

import SwiftUI

struct VersionView: View {
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .shadow(radius: 5)
                .frame(width: UIScreen.main.bounds.size.width-32, height: 250)
            
            // New Logo Needed
            VStack {
                Image("LogoEllipse")
                    .resizable()
                    .frame(width: 100, height: 100)
                Spacer()
                    .frame(height: 25)
                Text("최신 버전을 이용 중입니다.")
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(.init("DefaultFontColor"))
            }
        }
        
    }
}

struct VersionView_Previews: PreviewProvider {
    static var previews: some View {
        VersionView()
    }
}
