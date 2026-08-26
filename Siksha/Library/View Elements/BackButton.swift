//
//  CommonViews.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/13.
//
import SwiftUI

struct BackButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(.Icons.Common.Chevron.leftLarge)
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.iconWhiteIcon)
        }
        .accessibilityLabel("뒤로")
    }
}
#Preview {
    BackButton {}
        .padding()
        .background(Color.blackColor)
}
