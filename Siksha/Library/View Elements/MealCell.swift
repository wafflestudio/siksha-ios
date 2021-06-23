//
//  MealCell.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/13.
//

import SwiftUI

struct MealCell: View {
    let meal: Meal
    private var vegetarian: Bool = false
    private let orangeColor = Color.init("MainThemeColor")
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let formattedNumber = formatter.string(from: NSNumber(value: meal.price))!
        return formattedNumber
    }
    
    init(meal: Meal) {
        self.meal = meal
        if meal.etc.contains("No meat") {
            self.vegetarian = true
        }
    }
    
    var body: some View {
        HStack(alignment: .top) {
            Text("\(meal.nameKr)")
                .multilineTextAlignment(.leading)
                .font(.custom("NanumSquareOTFR", size: 15))
                .foregroundColor(.black)
                .padding(.top, 3)
            
            if vegetarian {
                Image("Vegetarian")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 18, height: 18)
                    .padding(.top, 3)
            }

            Spacer()
            
            Text(meal.price > 0 ? String(formattedPrice) : "-")
                .font(.custom("NanumSquareOTFR", size: 14))
                .foregroundColor(.black)
                .frame(width: 70)
                .padding(.top, 3)
            
            ZStack {
                if meal.reviewCnt > 0 {
                    Image(meal.score > 4.0 ? "Review-high" : meal.score <= 4.0 && meal.score >= 3.0 ? "Review-medium" : meal.score < 3.0 ? "Review-low" : "SettingsCell")
                        .resizable()
                        .frame(width: 48, height: 20)
                }

                Text(meal.reviewCnt > 0 ? String(format: "%.1f", meal.score) : "-")
                    .font(.custom("NanumSquareOTFB", size: 15))
                    .foregroundColor(meal.reviewCnt > 0 ? .white : .black)
            }
            .frame(width: 50, height: 20)
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
        
        return MealCell(meal: meal)
    }
}
