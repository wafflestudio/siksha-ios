//
//  MealInfoView.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/06.
//

import SwiftUI

private extension MealInfoView {
    var scoreSummary: some View {
        
        VStack {
            
            HStack (alignment: .bottom) {
                VStack(alignment: .center, spacing: 3) {
                    Text("\(String(format: "%.1f", viewModel.meal.score))점")
                        .font(.custom("NanumSquareOTFB", size: 32))
                        .foregroundColor(darkFontColor)
                    
                    RatingStar(.constant(viewModel.meal.score), size: 17)
                    
                }
                            
                VStack(alignment: .leading) {
                    Text("총 \(viewModel.meal.reviewCnt)명이 평가했어요!")
                        .font(.custom("NanumSquareOTFB", size: 12))
                        .foregroundColor(lightGrayColor)
                                    
                    HorizontalGraph(five: 10, four: 20, three: 30, two: 40, one: 50)
                }
                .padding(.leading, 20)
                
                Spacer()
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 10, trailing: 0))
            
            if showSubmitButton {
                if #available(iOS 14.0, *) {
                    NavigationLink(
                        destination: MealReviewView(viewModel.meal, mealInfoViewModel: viewModel),
                        label: {
                            ZStack {
                                Image("RateButton-new")
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 200, height: 32)

                                Text("나의 평가 남기기")
                                    .font(.custom("NanumSquareOTFB", size: 14))
                                    .foregroundColor(.white)
                            }
                        })
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 24, trailing: 0))
                } else {
                    NavigationLink(
                        destination: MealReviewView13(viewModel.meal),
                        label: {
                            ZStack {
                                Image("RateButton-new")
                                    .resizable()
                                    .renderingMode(.original)
                                    .frame(width: 200, height: 32)
                                    .padding(.top, 3)

                                Text("나의 평가 남기기")
                                    .font(.custom("NanumSquareOTFB", size: 12))
                                    .foregroundColor(.white)
                            }
                        })
                        .padding(EdgeInsets(top: 10, leading: 0, bottom: 24, trailing: 0))
                }
            }
        }
        
    }
    
    var reviewList: some View {
        List {
            ForEach(viewModel.mealReviews, id: \.id) { review in
                ReviewCell(review)
                    .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                    .listRowInsets(EdgeInsets())
                    .background(Color.white)
                    .onAppear {
                        viewModel.loadMoreReviewsIfNeeded(currentItem: review)
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
        .listStyle(PlainListStyle())
        .padding([.leading, .trailing], -10)
    }
    
    var pictureList: some View {
        ScrollView (.horizontal) {
            HStack {
//                ForEach
            }
        }.frame(height: 150)    }
    
}

struct MealInfoView: View {
    private let darkFontColor = Color.init("DarkFontColor")
    private let lightGrayColor = Color.init("LightGrayColor")
    private let orangeColor = Color.init("MainThemeColor")
    @ObservedObject var viewModel: MealInfoViewModel
    @State var showSubmitButton: Bool = true
    
    init(meal: Meal) {
        UINavigationBar.appearance().barTintColor = .white
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        
        UINavigationBar.appearance().titleTextAttributes = [.font: UIFont(name: "NanumSquareOTFB", size: 22)!, .foregroundColor: UIColor.init(white: 79/255, alpha: 1)]
        UITableView.appearance().separatorStyle = .none
        
        self.viewModel = MealInfoViewModel(meal)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                HStack {
                    orangeColor
                        .frame(height: 1)
                        .frame(maxWidth: .infinity)
                }
                .padding([.leading, .trailing], 12)
                
                scoreSummary
                
                
                HStack {
                    Text("메뉴 평가")
                        .font(.custom("NanumSquareOTFB", size: 16))
                        .foregroundColor(darkFontColor)
                    
                    Spacer()
                }
                                
                if viewModel.mealReviews.count > 0 {
                    reviewList
                } else {
                    Text("평가가 없습니다.")
                        .font(.custom("NanumSquareOTFB", size: 13))
                        .foregroundColor(lightGrayColor)
                        .padding(.top, 20)
                }
                
                Spacer()
            }
            .padding([.leading, .trailing], 36)
            .navigationBarTitle(
                Text(viewModel.meal.nameKr),
                displayMode: .inline
            )
            .onAppear {
                self.showSubmitButton = UserDefaults.standard.bool(forKey: "canSubmitReview")
                viewModel.mealReviews = []
                viewModel.currentPage = 1
                viewModel.loadMoreReviewsIfNeeded(currentItem: nil)
            }
        }
    }
}

struct MealInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let meal = Meal()
        meal.nameKr = "제육보쌈&막국수"
        meal.score = 4.1
        meal.reviewCnt = 40
        return MealInfoView(meal: meal)
    }
}
