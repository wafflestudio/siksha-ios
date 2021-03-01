//
//  RatingView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/05.
//

import SwiftUI

private extension RatingView {
    func starImage(_ index: Int) -> some View {
        var usingScore: Int
        if score == 0 && viewModel.scoreToRate != 0 {
            usingScore = Int(viewModel.scoreToRate * 2)
        } else {
            usingScore = score
        }
        var image: String
        if index*2<usingScore-1 {
            image = "RatingFilled"
        } else if index*2<usingScore {
            image = "RatingHalf"
        } else {
            image = "RatingEmpty"
        }
        
        return Image(image).resizable().frame(width: 32, height: 31)
    }
    
    var submitButton: some View {
        let canSubmit = appState.ratingEnabled
        
        let buttonEnabled = canSubmit && viewModel.scoreToRate > 0
        
        var buttonColor: Color = Color.init(white: 247/255)
        var buttonText: String = "별점 남기기"
        var buttonTextColor: Color = Color.init(white: 208/255)
        
        if buttonEnabled {
            buttonColor = orangeColor
            buttonTextColor = .white
        } else if !canSubmit {
            buttonText = "오늘 메뉴만 평가 가능합니다."
        }
        
        return Button(action: {
            viewModel.submitReview()
            appState.showSheet = false
        }) {
            ZStack(alignment: .top) {
                buttonColor
                Text(buttonText)
                    .font(.custom("NanumSquareOTFR", size: 17))
                    .foregroundColor(buttonTextColor)
                    .padding(.top, 15)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
        }
        .disabled(!buttonEnabled)
    }
}

// MARK: - Rating View

struct RatingView: View {
    private let fontColor = Color("DefaultFontColor")
    private let orangeColor = Color.init("MainThemeColor")
    
    @EnvironmentObject var appState: AppState
    @GestureState var score: Int = 0
    
    @ObservedObject var viewModel = RatingViewModel()
    
    var meal: Meal
    
    init(_ meal: Meal) {
        self.meal = meal
    }
    
    var scoreText: String {
        if meal.reviewCnt > 0 {
            return String(format: "%.1f", meal.score)
        } else {
            return "--"
        }
    }

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    Text("평점")
                        .font(.custom("NanumSquareOTFB", size: 15))
                        .foregroundColor(fontColor)
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            appState.showSheet = false
                        }
                    }) {
                        Image("Close")
                            .resizable()
                            .frame(width: 18, height: 18)
                    }
                }
                .padding([.leading, .trailing], 14)
                .padding([.top, .bottom], 12)
                
                orangeColor
                    .frame(height: 2)
                    .frame(maxWidth: .infinity)
                
                VStack(spacing: 30) {
                    Text(meal.nameKr)
                        .font(.custom("NanumSquareOTFB", size: 15))
                        .foregroundColor(fontColor)
                    
                    HStack(spacing: 20) {
                        Text("현재 평점")
                            .font(.custom("NanumSquareOTFR", size: 11))
                            .foregroundColor(fontColor)
                            .frame(width: 50, alignment: .trailing)
                        
                        Image("ScoreCircle")
                            .resizable()
                            .frame(width: 55, height: 55)
                            .overlay(
                                Text(scoreText)
                                    .font(.custom("NanumSquareOTFR", size: 15))
                                    .foregroundColor(.white)
                            )
                        
                        Text(String(format: "%d명", meal.reviewCnt))
                            .font(.custom("NanumSquareOTFR", size: 11))
                            .foregroundColor(fontColor)
                            .frame(width: 50, alignment: .leading)
                    }
                    
                    HStack(spacing: 10) {
                        ForEach(0..<5) { index in
                            starImage(index)
                        }
                    }
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .updating($score) { (value, state, transcation) in
                                state = Int(value.location.x/20.5)+1
                            }
                            .onEnded { value in
                                viewModel.scoreToRate = Double(Int(value.location.x/20.5+1))/2.0
                            }
                    )
                }
                .padding([.top, .bottom], 30)
                
                submitButton
            }
        }
    }
}

// MARK: - Preview

struct ReviewSubmitView_Previews: PreviewProvider {
    static var previews: some View {
        let meal = Meal()
        meal.nameKr = "올리브스테이크"
        
        return RatingView(meal)
    }
}
