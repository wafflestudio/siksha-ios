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
    
    init(meal: Meal) {
        self.meal = meal
        if meal.etc.contains("No meat") {
            self.vegetarian = true
        }
    }
    
    var body: some View {
        HStack {
            ZStack {
                Image("PriceBox")
                    .resizable()
                    .frame(width: 52, height: 23)

                Text(meal.price > 0 ? String(format: "%d", meal.price) : "-")
                    .font(.custom("NanumSquareOTFR", size: 13))
                    .foregroundColor(.white)
            }

            Text("\(meal.nameKr)")
                .font(.custom("NanumSquareOTFL", size: 14))
                .foregroundColor(.black)
            
            if vegetarian {
                Image("Vegetarian")
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 18, height: 18)
            }

            Spacer()

            Text(meal.reviewCnt > 0 ? String(format: "%.1f", meal.score) : "-")
                .font(.custom("NanumSquareOTFR", size: 13))
                .foregroundColor(.black)
        }
        .background(Color.white)
    }
}

struct MealCell_Previews: PreviewProvider {
    static var previews: some View {
        let meal = Meal()
        meal.nameKr = "음식"
        meal.reviewCnt = 1
        meal.score = 3.5
        
        return MealCell(meal: meal)
    }
}
