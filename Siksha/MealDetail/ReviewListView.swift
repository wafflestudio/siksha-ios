//
//  ReviewView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/30.
//

import SwiftUI

struct ReviewListView: View {
    private let lightGrayColor = Color.init("LightGrayColor")
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel = ReviewListViewModel()
    private var showOnlyImageReviews: Bool
    
    let meal: Meal
    
    init(_ meal: Meal, _ images: Bool) {
        self.meal = meal
        self.showOnlyImageReviews = images
    }
    
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 10, height: 16)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.reviews.count > 0 {
                List {
                    ForEach(viewModel.reviews, id: \.id) { review in
                        ReviewCell(review, true)
                            .padding(EdgeInsets(top: 16, leading: 8, bottom: 4, trailing: 0))
                            .listRowInsets(EdgeInsets())
                            .background(Color.white)
                            .onAppear {
                                viewModel.loadMoreReviewsIfNeeded(currentItem: review, showOnlyImageReviews)
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
                    Text("리뷰가 없습니다.")
                        .font(.custom("NanumSquareOTFB", size: 13))
                        .foregroundColor(lightGrayColor)
                        .padding(.top, 20)
                    
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            }
        }
        .customNavigationBar(title: showOnlyImageReviews ? "사진 리뷰 모아보기" : "리뷰")
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.meal = meal
            viewModel.reviews = []
            viewModel.currentPage = 1
            viewModel.loadMoreReviewsIfNeeded(currentItem: nil, showOnlyImageReviews)
        }
    }
}

//struct ReviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        ReviewView()
//    }
//}
