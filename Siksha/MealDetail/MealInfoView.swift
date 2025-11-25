//
//  MealInfoView.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/06.
//

import SwiftUI
import Kingfisher

struct MealInfoView: View {
    @Environment(\.menuViewModel) var menuViewModel: MenuViewModel?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var viewModel: MealInfoViewModel
    @State var showSubmitButton: Bool = true
    @State var showDetailImage: Bool = false
    
    init(viewModel: MealInfoViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                heartSection
                separator
                reviewSummary
                separator
                reviewListSection
            }
        }
        .background(Color.backgroundPrimary)
        .customNavigationBar(title: viewModel.meal.nameKr)
        .navigationBarItems(leading: backButton)
        .onAppear {
            self.showSubmitButton = UserDefaults.standard.bool(forKey: "canSubmitReview")
            viewModel.mealReviews = []
            viewModel.loadReviews()
            viewModel.loadImages()
            viewModel.loadDistribution()
            viewModel.loadKeywordDistribution()
        }
    }
}

private struct ReviewList: View {
    @ObservedObject var viewModel: MealInfoViewModel
    
    var body: some View {
        VStack(spacing: 21) {
            titleLabel
            
            if viewModel.mealReviews.isEmpty {
                Text("아직 작성된 리뷰가 없어요")
                    .customFont(font: .text14(weight: .Bold))
                    .foregroundStyle(Color.gray600)
            } else {
                VStack(spacing: 32) {
                    ForEach(viewModel.mealReviews, id: \.id) { review in
                        ReviewRow(viewModel: ReviewRowViewModel(review: review, showImage: false))
                    }
                }
                
                HStack {
                    Spacer()
                    
                    //                if viewModel.hasMorePages {
                    NavigationLink(destination: ReviewListView(Meal(), false)) {
                        HStack(spacing: 11) {
                            Text("리뷰 더보기")
                                .foregroundStyle(Color.gray600)
                                .customFont(font: .text12(weight: .Bold))
                            
                            Image("Arrow")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 5, height: 8)
                                .foregroundStyle(Color.gray600)
                        }
                    }
                    //                }
                }
            }
        }
    }
    
    var titleLabel: some View {
        HStack(spacing: 0) {
                Text("리뷰")
                    .customFont(font: .text18(weight: .Bold))
                    .foregroundColor(.blackColor)
                
                Spacer()
        }
    }
}

private extension MealInfoView {
    var heartSection: some View {
        VStack(spacing: 0) {
            Button {
                viewModel.toggleLike()
            } label: {
                Image("Heart")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(viewModel.meal.isLiked ? Color.accentLike : Color.gray200)
                    .padding(.top, 20)
            }
            
            HStack(spacing: 0) {
                Text("찜 \(viewModel.meal.likeCnt)개")
                    .customFont(font: .text13(weight: .Bold))
                    .foregroundColor(Color.blackColor)
            }
            .padding(.bottom, 18)
        }
    }
    
    var separator: some View {
        Color.gray100
            .frame(height: 10)
            .frame(maxWidth: .infinity)
    }
    
    var reviewSummary: some View {
        VStack(spacing: 18) {
            scoreSummary
                .padding(.horizontal, 16)
            
            Button(action: {}) {
                NavigationLink(
                    destination: MealReviewView(viewModel.meal, mealInfoViewModel: viewModel),
                    label: {
                        Text("나의 평가 남기기")
                            .customFont(font: .text14(weight: .ExtraBold))
                            .foregroundStyle(Color.whiteColor
                            )
                            .padding(.vertical, 7)
                            .padding(.horizontal, 23)
                            .background(Color.orange500)
                            .cornerRadius(50)
                    })
            }
        }
        .padding(.top, 32)
        .padding(.bottom, 32)
    }
    
    var reviewListSection: some View {
        VStack(spacing: 33) {
            if !viewModel.images.isEmpty {
                PhotoReviewView(viewModel: viewModel)
            }
            
            ReviewList(viewModel: viewModel)
        }
        .padding(.top, 17)
        .padding(.horizontal, 16)
        .padding(.bottom, 65)
    }
    
    var scoreSummary: some View {
        HStack (alignment: .center, spacing: 12) {
            VStack(alignment: .center, spacing: 0) {
                Text("\(String(format: "%.1f", viewModel.meal.score))")
                    .customFont(font: .text32(weight: .Bold))
                    .foregroundColor(Color.blackColor)
                
                StarRateView(rate: viewModel.meal.score, spacing: 1)
                    .frame(height: 12)
                
                Spacer().frame(height: 10)
                
                Text("후기 \(viewModel.meal.reviewCnt)개")
                    .customFont(font: .text14(weight: .Regular))
                    .foregroundStyle(Color.blackColor)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background {
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(Color.gray200, lineWidth: 1)
            }
            
            VStack(spacing: 6) {
                KeywordRateRow(summary: viewModel.tasteSummary)
                KeywordRateRow(summary: viewModel.priceSummary)
                KeywordRateRow(summary: viewModel.compositionSummary)
            }
        }
    }
    
//    var pictureList: some View {
//        ScrollView(.horizontal, showsIndicators: false) {
//            HStack {
//                ThumbnailImage(viewModel.images[0])
//                if viewModel.images.count >= 2 {
//                    ThumbnailImage(viewModel.images[1])
//                }
//                if viewModel.images.indices.contains(2) {
//                    NavigationLink(
//                        destination: ReviewListView(viewModel.meal, true),
//                        label: {
//                            ZStack {
//                                RemoteImage(url: viewModel.images[2])
//                                    .frame(width: 120, height: 120)
//                                    .clipped()
//                                
//                                Text(viewModel.totalImageCount-3 > 0 ? "+\n\(viewModel.totalImageCount-3)건 더 보기" : "+\n더 보기")
//                                    .foregroundColor(.whiteColor)
//                                    .font(.custom("NanumSquareOTFB", size: 12))
//                                    .multilineTextAlignment(.center)
//                            }
//                            .background(Color.backgroundPrimary)
//                            .opacity(0.5)
//                            .cornerRadius(8)
//                        })
//                }
//                Spacer()
//            }
//        }
//        .padding(.leading, 16)
//    }
    
//    var reviewList: some View {
//        VStack {
//            ForEach(viewModel.mealReviews, id: \.id) { review in
//                ReviewCell(review, false)
//                    .padding(EdgeInsets(top: 12, leading: 8, bottom: 0, trailing: 0))
//                    .listRowInsets(EdgeInsets())
//                    .background(Color.backgroundPrimary)
//            }
//            if viewModel.hasMorePages {
//                NavigationLink(destination: ReviewListView(viewModel.meal, false)) {
//                    HStack(alignment: .center) {
//                        Spacer()
//                        
//                        Text("리뷰 더 보기")
//                            .font(.custom("NanumSquareOTFB", size: 13))
//                            .foregroundColor(.gray600)
//                        
//                        Image("Arrow")
//                            .resizable()
//                            .frame(width: 7.5, height: 12)
//                            .padding(.trailing, 8)
//                            .padding(.bottom, 2)
//                    }
//                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 10, trailing: 16))
//                }
//            }
//        }
//        .padding(.bottom, 30)
//    }
    
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
}

private struct MealInfoPreview {
    static var previews: some View {
        let meal = Meal()
        meal.id = 176933
        meal.nameKr = "제육보쌈&막국수"
        meal.score = 4.1
        meal.reviewCnt = 40
        return MealInfoView(viewModel: MealInfoViewModel(meal: meal))
    }
}



#Preview {
    NavigationView {
        MealInfoPreview.previews
    }
}
