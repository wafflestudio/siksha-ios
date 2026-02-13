//
//  ReviewSection.swift
//  Siksha
//
//  Created by Jihyeon on 11/25/25.
//

import SwiftUI

struct ReviewSection: View {
    @ObservedObject var viewModel: MealInfoViewModel
    
    var body: some View {
        VStack(spacing: 21) {
            titleLabel
            
            if viewModel.mealReviews.isEmpty {
                Text("아직 작성된 리뷰가 없어요")
                    .customFont(font: .text14(weight: .Bold))
                    .foregroundStyle(Color.gray600)
            } else {
                VStack(spacing: 32) {
                    ForEach(viewModel.mealReviews, id: \.id) { review in
                        ReviewRow(review)
                    }
                }
                
                HStack {
                    Spacer()
                    
                    if viewModel.hasMorePages {
                        NavigationLink(destination: ReviewListView(mealID: viewModel.meal.id)) {
                            HStack(spacing: 11) {
                                Text("리뷰 더보기")
                                    .foregroundStyle(Color.gray600)
                                    .customFont(font: .text12(weight: .Bold))
                                
                                Image("Arrow")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 5, height: 8)
                                    .foregroundStyle(Color.gray600)
                            }
                        }
                    }
                }
            }
        }
    }
    
    var titleLabel: some View {
        HStack(spacing: 0) {
                Text("리뷰")
                    .customFont(font: .text18(weight: .Bold))
                    .foregroundColor(.blackColor)
                
                Spacer()
        }
    }
}
