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
                    .renderingMode(.original)
                    .frame(width: 13, height: 21)
                    .padding(.trailing, 5)
                
                Text("설정")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(.init("Gray600"))
            }
        }
        .frame(width: 100, alignment: .leading)
    }
}
