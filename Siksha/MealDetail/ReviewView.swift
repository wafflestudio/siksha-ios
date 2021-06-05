//
//  ReviewView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/30.
//

import SwiftUI

struct ReviewView: View {
    
    private let lightGrayColor = Color.init("LightGrayColor")
    
    @ObservedObject var viewModel: ReviewViewModel
    private var showOnlyImageReviews: Bool
    
    let meal: Meal

    init(_ meal: Meal, _ images: Bool) {
        self.meal = meal
        self.showOnlyImageReviews = images
        self.viewModel = ReviewViewModel(meal)
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack {
                
                NavigationBar(title: "리뷰", showBack: true)
                
                if showOnlyImageReviews {
                    
                    if viewModel.mealImageReviews.count > 0 {
                        List {
                            ForEach(viewModel.mealImageReviews, id: \.id) { review in
                                ReviewCell(review, true)
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
                    } else {
                        VStack {
                            Text("리뷰가 없습니다.")
                                .font(.custom("NanumSquareOTFB", size: 13))
                                .foregroundColor(lightGrayColor)
                                .padding(.top, 20)
                        }
                        .frame(maxWidth: .infinity)
                        
                    }
                    
                } else {
                    
                    if viewModel.mealReviews.count > 0 {
                        List {
                            ForEach(viewModel.mealReviews, id: \.id) { review in
                                ReviewCell(review, true)
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
                    } else {
                        VStack {
                            Text("리뷰가 없습니다.")
                                .font(.custom("NanumSquareOTFB", size: 13))
                                .foregroundColor(lightGrayColor)
                                .padding(.top, 20)
                        }
                        .frame(maxWidth: .infinity)
                        
                    }
                }
                
            }
            .onAppear {
                viewModel.mealReviews = []
                viewModel.currentPage = 1
                viewModel.loadMoreReviewsIfNeeded(currentItem: nil)
                viewModel.loadMoreImageReviewsIfNeeded(currentItem: nil)
            }
            .navigationBarHidden(true)


        }

    }
}

//struct ReviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReviewView()
//    }
//}
