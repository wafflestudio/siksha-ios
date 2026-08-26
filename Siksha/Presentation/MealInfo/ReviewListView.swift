//
//  ReviewView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/30.
//

import SwiftUI

struct ReviewListView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject var viewModel: ReviewListViewModel

    init(mealID: Int, imageReviewOnly: Bool = false) {
        self._viewModel = StateObject(
            wrappedValue: ReviewListViewModel(
                mealID: mealID,
                imageOnly: imageReviewOnly,
                fetchMealReviewsUseCase: AppContainer.shared.useCases.fetchMealReviewsUseCase,
                fetchMealImageReviewsUseCase: AppContainer.shared.useCases.fetchMealImageReviewsUseCase
            ))
    }

    var body: some View {
        ZStack {
            if !viewModel.reviews.isEmpty {
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 32) {
                        ForEach(viewModel.reviews, id: \.self) { review in
                            ReviewRow(review)
                                .onAppear {
                                    viewModel.loadMoreReviewsIfNeeded(current: review)
                                }
                        }

                        if viewModel.hasMorePages && viewModel.getReviewStatus == .loading {
                            HStack {
                                Spacer()
                                ActivityIndicator(isAnimating: .constant(true), style: .medium)
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .padding(.top, 24)
                    .padding(.bottom, 65)
                }
            } else if viewModel.getReviewStatus == .loading {
                VStack {
                    Spacer()
                    HStack {
                        ActivityIndicator(isAnimating: .constant(true), style: .medium)
                    }
                    .frame(maxWidth: .infinity)
                    Spacer()
                }
            } else {
                VStack {
                    Spacer()
                    Text("리뷰가 없습니다.")
                        .customFont(font: .text13(weight: .Bold))
                        .foregroundColor(Color.gray600)
                        .padding(.top, 20)

                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .customNavigationBar(title: viewModel.imageOnly ? "사진 리뷰" : "전체 리뷰")
        .background(Color.backgroundPrimary)
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.reviews = []
            viewModel.currentPage = 1
            viewModel.loadMoreReviewsIfNeeded()
        }
    }

    private var backButton: some View {
        BackButton {
            dismiss()
        }
    }
}
