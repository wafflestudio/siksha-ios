//
//  MenuRow.swift
//  Siksha
//
//  Created by You Been Lee on 2021/02/11.
//
import SwiftUI

struct RestaurantOrderRow: View {
    var text: String
    var isLiked: Bool = true
    var isVisible: Bool = true
    var onLikeTap: () -> Void = {}
    var onVisibilityTap: () -> Void = {}
    
    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            ZStack(alignment: .leading) {
                Color.elementTooltip2.cornerRadius(12).shadow(color: .black.opacity(0.16), radius: 1.5, x: 0, y: 0)
                
                HStack(alignment: .center, spacing: 4) {
                    Button(action: onLikeTap) {
                        Image(isLiked ? .Icons.Common.Star.filled20 : .Icons.Common.Star.unfilled20)
                            .foregroundStyle(isLiked ? Color.orange500 : Color.iconStar)
                    }
                    .buttonStyle(.plain)
                    Text(text)
                        .customFont(font: .text13(weight: .Bold))
                        .foregroundColor(Color.gray800)
                        .padding(.vertical, 11)
                    Spacer()
                    Button(action: onVisibilityTap) {
                        Image(isVisible ? .Icons.Common.eyeOpened : .Icons.Common.eyeClosed)
                            .resizable()
                            .frame(width: 24, height: 24)
                            .foregroundStyle(isVisible ? Color.orange400 : Color.gray500)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 12)
            }
            .frame(height: 40)
            .padding(.vertical, 6)
            .padding(.horizontal, 8)
            .background(Color.gray50)
            
            Image("ReorderHandle")
                .renderingMode(.template)
                .foregroundStyle(Color.iconGrayIcon)
                .padding(.leading, 14)
                .padding(.trailing, 13)
        }
        .background(Color.backgroundSecondary)
    }
}

struct MenuRow_Previews: PreviewProvider {
    static var previews: some View {
        RestaurantOrderRow(
            text: "302동 식당",
            isLiked: false,
            isVisible: false
        )
    }
}
