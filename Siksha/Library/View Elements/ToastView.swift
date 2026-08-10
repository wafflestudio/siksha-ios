//
//  ToastView.swift
//  Siksha
//
//  Created by 이수민 on 10/5/25.
//

import SwiftUI

struct ToastView: View {
    enum ToastType {
        case error
        case check

        var image: Image {
            switch self {
            case .error: return Image(.Icons.Common.alertCircle)
            case .check: return Image("CheckCircleOrange")
            }
        }
    }

    let type: ToastType
    let message: String
    let bottomMargin: CGFloat
    let isVisible: Bool

    init(type: ToastType = .error, message: String, bottomMargin: CGFloat = 20, isVisible: Bool) {
        self.type = type
        self.message = message
        self.bottomMargin = bottomMargin
        self.isVisible = isVisible
    }

    var body: some View {
        VStack {
            Spacer()

            ZStack(alignment: .center) {
                RoundedRectangle(cornerRadius: 8.0)
                    .fill(Color.backgroundToast)

                HStack(spacing: 0) {
                    type.image
                        .frame(width: 14, height: 14)
                        .padding(.trailing, 10)

                    Text(message)
                        .customFont(font: .text12(weight: .Bold))
                        .lineLimit(1)
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
            }
            .fixedSize(horizontal: true, vertical: false)
            .frame(height: 30)
            .opacity(isVisible ? 1 : 0)
            .animation(.easeIn(duration: 0.2), value: isVisible)
            .padding(.bottom, bottomMargin)
        }
    }
}
