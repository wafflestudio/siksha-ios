//
//  KeywordSectionView.swift
//  Siksha
//
//  Created by Jihyeon on 11/25/25.
//

import SwiftUI

struct KeywordSectionView: View {
    @ObservedObject var viewModel: MealReviewViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 5) {
                Text("어떤 점이 얼마나 좋았나요?")
                    .customFont(font: .text18(weight: .ExtraBold))
                    .foregroundStyle(Color.blackColor)

                Text("(필수)")
                    .customFont(font: .text12(weight: .Bold))
                    .foregroundStyle(Color.gray700)

                Spacer()
            }

            Spacer().frame(height: 18)

            VStack(spacing: 22) {
                KeywordSelectionView(type: .taste, viewModel: viewModel)
                KeywordSelectionView(type: .price, viewModel: viewModel)
                KeywordSelectionView(type: .composition, viewModel: viewModel)
            }
        }
        .padding(.horizontal, 16)
    }
}
