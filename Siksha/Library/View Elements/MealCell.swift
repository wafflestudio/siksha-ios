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
    private let orangeColor = Color.init("main")
    private let grayColor = Color.init("Gray900")
    private let lightGrayColor = Color.init("Gray700")
    private let blackColor = Color.init("BlackColor")
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedNumber = formatter.string(from: NSNumber(value: viewModel.meal.price))!
        return formattedNumber
    }
    
    init(viewModel: MealInfoViewModel) {
        self.viewModel = viewModel
        if viewModel.meal.etc.contains("No meat") {
            self.vegetarian = true
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(viewModel.meal.nameKr)")
                .multilineTextAlignment(.leading)
                .font(.custom("NanumSquareOTFR", size: 15))
                .foregroundColor(blackColor)
                .padding(.top, 3)
            
            if vegetarian {
                Image("Vegetarian")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 18, height: 18)
                    .padding(.top, 3)
            }

            Spacer()
            
            Text(viewModel.meal.price > 0 ? String(formattedPrice) : "-")
                .font(.custom("NanumSquareOTFR", size: 14))
                .foregroundColor(blackColor)
                .frame(width: 50)
                .padding(.top, 3)

            Text(viewModel.meal.reviewCnt > 0 ? String(format: "%.1f", viewModel.meal.score) : "-")
                .font(.custom("NanumSquareOTFB", size: 15))
                .foregroundColor(blackColor)
                .frame(width: 35, height: 20)
                .padding(.top, 0.5)
            
            Button(action: {
            viewModel.toggleLike()
            }){
                Image(viewModel.meal.isLiked ? "Heart-selected" : "Heart-default")
                    .frame(width: 35, height: 20)
            }
        }
        .background(Color.white)
    }
}

struct MealCell_Previews: PreviewProvider {
    static var previews: some View {
        let meal = Meal()
        meal.nameKr = "음식"
        meal.reviewCnt = 1
        meal.score = 4.1
        meal.price = 4000
        
        return MealCell(viewModel: MealInfoViewModel(meal: meal))
    }
}
