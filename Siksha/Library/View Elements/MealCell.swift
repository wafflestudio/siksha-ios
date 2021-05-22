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
        HStack {

            Text("\(meal.nameKr)")
                .font(.custom("NanumSquareOTFL", size: 15))
                .foregroundColor(.black)
            
            if vegetarian {
                Image("Vegetarian")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 18, height: 18)
            }

            Spacer()
            
            Text(meal.price > 0 ? String(formattedPrice) : "-")
                .font(.custom("NanumSquareOTFR", size: 13))
                .foregroundColor(.black)
            
            ZStack {
                Image(meal.score > 4.0 ? "Review-high" : meal.score <= 4.0 && meal.score >= 3.0 ? "Review-medium" : meal.score < 3.0 && meal.score > 0 ? "Review-low" : "SettingsCell")
                    .resizable()
                    .frame(width: 48, height: 20)

                Text(meal.reviewCnt > 0 ? String(format: "%.1f", meal.score) : "-")
                    .font(.custom("NanumSquareOTFR", size: 13))
                    .foregroundColor(meal.reviewCnt > 0 ? .white : .black)
            }
            .padding(.leading, 8)
        }
        .background(Color.white)
    }
}

struct MealCell_Previews: PreviewProvider {
    static var previews: some View {
        let meal = Meal()
        meal.nameKr = "음식"
        meal.reviewCnt = 1
        meal.score = 4.2
        meal.price = 4000
        
        return MealCell(meal: meal)
    }
}
