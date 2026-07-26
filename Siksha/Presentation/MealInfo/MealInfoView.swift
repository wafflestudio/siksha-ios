//
//  MealInfoView.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/06.
//

import Kingfisher
import SwiftUI

struct MealInfoView: View {
    @Environment(\.menuViewModel) var menuViewModel: MenuViewModel?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @StateObject var viewModel: MealInfoViewModel
    @State var showDetailImage: Bool = false

    init(viewModel: MealInfoViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heartSection
                separator
                reviewSummary
                separator
                reviewListSection
            }
        }
        .background(Color.backgroundPrimary)
        .customNavigationBar(title: viewModel.meal.nameKr)
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.mealReviews = []
            viewModel.loadReviews()
            viewModel.loadImages()
            viewModel.loadDistribution()
            viewModel.loadKeywordDistribution()
        }
    }
}

private extension MealInfoView {
    var heartSection: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.toggleLike()
            } label: {
                Image("Heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(viewModel.meal.isLiked ? Color.accentLike : Color.gray200)
                    .padding(.top, 20)
            }
            .disabled(viewModel.isUpdatingLike)

            HStack(spacing: 0) {
                Text("찜 \(viewModel.meal.likeCount)개")
                    .customFont(font: .text13(weight: .Bold))
                    .foregroundColor(Color.blackColor)
            }
            .padding(.bottom, 18)
        }
    }

    var separator: some View {
        Color.gray100
            .frame(height: 10)
            .frame(maxWidth: .infinity)
    }

    var reviewSummary: some View {
        VStack(spacing: 18) {
            scoreSummary
                .padding(.horizontal, 16)

            Button(action: {}) {
                NavigationLink(
                    destination: MealReviewView(viewModel.meal, mealInfoViewModel: viewModel),
                    label: {
                        Text("나의 평가 남기기")
                            .customFont(font: .text14(weight: .ExtraBold))
                            .foregroundStyle(Color.textButton)
                            .padding(.vertical, 7)
                            .padding(.horizontal, 23)
                            .background(Color.orange500)
                            .cornerRadius(50)
                    })
            }
        }
        .padding(.top, 32)
        .padding(.bottom, 32)
    }

    var reviewListSection: some View {
        VStack(spacing: 33) {
            if !viewModel.images.isEmpty {
                PhotoReviewSection(viewModel: viewModel)
            }

            ReviewSection(viewModel: viewModel)
        }
        .padding(.top, 17)
        .padding(.horizontal, 16)
        .padding(.bottom, 65)
    }

    var scoreSummary: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .center, spacing: 0) {
                Text("\(String(format: "%.1f", viewModel.meal.score))")
                    .customFont(font: .text32(weight: .Bold))
                    .foregroundColor(Color.blackColor)

                StarRateView(rate: viewModel.meal.score, spacing: 1)
                    .frame(height: 12)

                Spacer().frame(height: 10)

                Text("후기 \(viewModel.meal.reviewCount)개")
                    .customFont(font: .text14(weight: .Regular))
                    .foregroundStyle(Color.blackColor)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.backgroundSecondary)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(Color.gray200, lineWidth: 1)
                    )
            }

            VStack(spacing: 6) {
                KeywordRateRow(summary: viewModel.tasteSummary)
                KeywordRateRow(summary: viewModel.priceSummary)
                KeywordRateRow(summary: viewModel.compositionSummary)
            }
        }
    }

    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .foregroundColor(.white)
        }
    }
}

@MainActor
private struct MealInfoPreview {
    static var previews: some View {
        let meal = MenuItemDisplayModel(
            id: 176933,
            code: "",
            nameKr: "제육보쌈&막국수",
            nameEn: "",
            price: 0,
            score: 4.1,
            reviewCount: 40,
            isLiked: false,
            likeCount: 0,
            imageURLStrings: []
        )
        return MealInfoView(
            viewModel: MealInfoViewModel(
                meal: meal,
                fetchMenuUseCase: AppContainer.shared.useCases.fetchMenuUseCase,
                fetchMealReviewsUseCase: AppContainer.shared.useCases.fetchMealReviewsUseCase,
                fetchMealImageReviewsUseCase: AppContainer.shared.useCases.fetchMealImageReviewsUseCase,
                fetchMealReviewScoreDistributionUseCase: AppContainer.shared.useCases
                    .fetchMealReviewScoreDistributionUseCase,
                fetchMealReviewKeywordDistributionUseCase: AppContainer.shared.useCases
                    .fetchMealReviewKeywordDistributionUseCase,
                updateMenuLikeUseCase: AppContainer.shared.useCases.updateMenuLikeUseCase
            ))
    }
}

#Preview {
    NavigationView {
        MealInfoPreview.previews
    }
}
