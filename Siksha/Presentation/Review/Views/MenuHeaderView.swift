//
//  MenuHeaderView.swift
//  Siksha
//
//  Created by Jihyeon on 11/25/25.
//

import SwiftUI

struct MenuRatingHeaderView: View {
    let menuName: String
    @Binding var score: Int

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
                Text(menuName)
                    .customFont(font: .text20(weight: .ExtraBold))
                    .foregroundColor(Color.blackColor)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text("\(menuName.inspectFinalConsonant() == .hasConsonant ? "은" : "는") 어땠나요?")
                    .customFont(font: .text20(weight: .Bold))
                    .foregroundColor(Color.gray700)
            }

            Spacer().frame(height: 24)

            Text("별점을 선택해주세요.")
                .customFont(font: .text14(weight: .Bold))
                .foregroundStyle(Color.gray700)

            Spacer().frame(height: 9)

            StarRateView(rate: $score, spacing: 3)
                .frame(height: 25)

            Spacer().frame(height: 9)

            Text("\(score)")
                .customFont(font: .text20(weight: .Bold))
                .foregroundColor(Color.blackColor)
        }
        .padding(.horizontal, 15.5)
        .padding(EdgeInsets(top: 41, leading: 0, bottom: 19, trailing: 0))
    }
}
