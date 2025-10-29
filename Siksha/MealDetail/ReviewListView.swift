//
//  ReviewView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/30.
//

import SwiftUI

struct ReviewListView: View {
    private let lightGrayColor = Color.gray600
    
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
                .scaledToFit()
                .frame(width: 24, height: 24)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                .foregroundColor(.white)
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 32) {
                if showOnlyImageReviews {
                    ForEach(0..<10) { _ in
                        ReviewRow(showImage: true)
                    }
                } else {
                    ReviewRow(showImage: true)
                    ForEach(0..<10) { _ in
                        ReviewRow(showImage: false)
                    }
                }
                
                //            if viewModel.reviews.count > 0 {
                //                List {
                //                    ForEach(viewModel.reviews, id: \.id) { review in
                //                        ReviewCell(review, true)
                //                            .padding(EdgeInsets(top: 16, leading: 8, bottom: 4, trailing: 0))
                //                            .listRowInsets(EdgeInsets())
                //                            .background(Color.backgroundPrimary)
                //                            .onAppear {
                //                                viewModel.loadMoreReviewsIfNeeded(currentItem: review, showOnlyImageReviews)
                //                            }
                //                    }
                //                    if viewModel.hasMorePages && viewModel.getReviewStatus == .loading {
                //                        HStack {
                //                            Spacer()
                //                            ActivityIndicator(isAnimating: .constant(true), style: .medium)
                //                            Spacer()
                //                        }
                //                    }
                //                }
                //                .listStyle(PlainListStyle())
                //            } else if viewModel.getReviewStatus == .loading {
                //                VStack {
                //                    Spacer()
                //                    HStack {
                //                        ActivityIndicator(isAnimating: .constant(true), style: .medium)
                //                    }
                //                    .frame(maxWidth: .infinity)
                //                    Spacer()
                //                }
                //            } else {
                //                VStack {
                //                    Text("리뷰가 없습니다.")
                //                        .font(.custom("NanumSquareOTFB", size: 13))
                //                        .foregroundColor(lightGrayColor)
                //                        .padding(.top, 20)
                //
                //                    Spacer()
                //                }
                //                .frame(maxWidth: .infinity)
                //            }
            }
            .padding(.horizontal, 14)
            .padding(.top, 24)
            .padding(.bottom, 65)
        }
        .customNavigationBar(title: showOnlyImageReviews ? "사진 리뷰" : "전체 리뷰")
        .background(Color.backgroundPrimary)
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.meal = meal
            viewModel.reviews = []
            viewModel.currentPage = 1
            viewModel.loadMoreReviewsIfNeeded(currentItem: nil, showOnlyImageReviews)
        }

    }
}

#Preview {
    NavigationStack {
        ReviewListView(Meal(), true)
    }
}

