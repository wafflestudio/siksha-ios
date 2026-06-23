//
//  MealCell.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/13.
//

import SwiftUI

struct MealCell: View {
    @ObservedObject var viewModel: MealInfoViewModel
    private var vegetarian: Bool = false
    private let orangeColor = Color.init("Color/Foundation/Orange/500")
    private let grayColor = Color.init("Color/Foundation/Gray/900")
    private let lightGrayColor = Color.init("Color/Foundation/Gray/700")
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedNumber = formatter.string(from: NSNumber(value: viewModel.meal.price))!
        return formattedNumber
    }
    
    init(viewModel: MealInfoViewModel) {
        self.viewModel = viewModel
        if viewModel.meal.imageURLStrings.contains("No meat") {
            self.vegetarian = true
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(viewModel.meal.nameKr)")
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 168,alignment: .leading)
                .customFont(font: .text15(weight: .Regular))
                .foregroundColor(.blackColor)
            
            if vegetarian {
                Image("Vegetarian")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 18, height: 18)
            }

            Spacer()
            if viewModel.meal.price < 10000{
                Text(viewModel.meal.price > 0 ? String(formattedPrice) : "-")
                    .customFont(font: .text14(weight:.Regular))
                    .foregroundColor(.blackColor)
                    .frame(width: 38)
            }
            else{
                Text(viewModel.meal.price > 0 ? String(formattedPrice) : "-")
                    .customFont(font: .text14(weight:.Regular))
                    .foregroundColor(.blackColor)
            }
            Spacer()
                .frame(width:16)
                Text(viewModel.meal.reviewCount > 0 ? String(format: "%.1f", viewModel.meal.score) : "-")
                    .customFont(font: .text14(weight: .Regular))
                    .foregroundColor(.blackColor)
                    .frame(width:23)
                    
            Spacer()
                .frame(width:16)

            Button(action: {
            viewModel.toggleLike()
            }){
                Image(viewModel.meal.isLiked ? "Heart-selected" : "Heart-default")
                    .frame(width: 24, height: 24)
            }
        }
        .padding(.zero)
        .background(Color.backgroundSecondary)
    }
}

struct MealCell_Previews: PreviewProvider {
    static var previews: some View {
        let meal = MenuItemDisplayModel(
            id: 0,
            code: "",
            nameKr: "음식",
            nameEn: "",
            price: 4000,
            score: 4.1,
            reviewCount: 1,
            isLiked: false,
            likeCount: 0,
            imageURLStrings: []
        )
        
        return MealCell(viewModel: MealInfoViewModel(
            meal: meal,
            mealInfoUseCase: PreviewMealInfoUseCase(),
            mealReviewUseCase: PreviewMealReviewUseCase()
        ))
    }
    
    private final class PreviewMealInfoUseCase: MealInfoUseCase {
        func fetchMenu(menuId: Int) async throws -> MenuModel {
            MenuModel(
                id: menuId,
                code: "",
                nameKr: "음식",
                nameEn: "",
                price: 4000,
                score: 4.1,
                reviewCount: 1,
                isLiked: false,
                likeCount: 0,
                imageURLStrings: []
            )
        }
        
        func toggleMenuLike(menu: MenuModel) async throws -> MenuModel {
            MenuModel(
                id: menu.id,
                code: menu.code,
                nameKr: menu.nameKr,
                nameEn: menu.nameEn,
                price: menu.price,
                score: menu.score,
                reviewCount: menu.reviewCount,
                isLiked: !menu.isLiked,
                likeCount: max(0, menu.likeCount + (menu.isLiked ? -1 : 1)),
                imageURLStrings: menu.imageURLStrings
            )
        }
    }
    
    private final class PreviewMealReviewUseCase: MealReviewUseCase {
        func fetchReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel {
            ReviewPageModel(totalCount: 0, hasNext: false, reviews: [])
        }
        
        func fetchImageReviews(menuId: Int, page: Int, perPage: Int) async throws -> ReviewPageModel {
            ReviewPageModel(totalCount: 0, hasNext: false, reviews: [])
        }
        
        func fetchScoreDistribution(menuId: Int) async throws -> [Int] {
            []
        }
        
        func fetchKeywordDistribution(menuId: Int) async throws -> KeywordDistributionModel {
            KeywordDistributionModel(
                tasteKeyword: "",
                tasteCount: 0,
                tasteTotal: 0,
                priceKeyword: "",
                priceCount: 0,
                priceTotal: 0,
                foodCompositionKeyword: "",
                foodCompositionCount: 0,
                foodCompositionTotal: 0
            )
        }
        
        func fetchCommentRecommendation(score: Int) async throws -> String {
            ""
        }
        
        func submitReview(_ submission: MealReviewSubmissionModel) async throws {}
        
        func editReview(reviewId: Int, submission: MealReviewSubmissionModel) async throws {}
        
        func likeReview(reviewId: Int) async throws {}
        
        func unlikeReview(reviewId: Int) async throws {}
    }
}
