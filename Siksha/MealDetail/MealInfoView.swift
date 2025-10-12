//
//  MealInfoView.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/06.
//

import SwiftUI

struct MealInfoView: View {
    private let darkFontColor = Color.blackColor
    private let lightGrayColor = Color.gray600
    private let orangeColor = Color.orange500
    
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
                    Image("Heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundStyle(Color.accentLike)
                        .padding(.top, 20)
                    
                    HStack(spacing: 0) {
                        Text("찜 \(viewModel.meal.likeCnt)개")
                            .customFont(font: .text13(weight: .Bold))
                            .foregroundColor(Color.blackColor)
                    }
                    .padding(.bottom, 18)
                    
                    separator
                    
                    scoreSummary
                        .padding(.top, 32)
                        .padding(.bottom, 18)
                        .padding(.horizontal, 16)
                    
                    Button(action: {}) {
                        NavigationLink(
                            destination: MealReviewView(viewModel.meal, mealInfoViewModel: viewModel)
                                .environment(\.menuViewModel, menuViewModel),
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
                    .padding(.bottom, 32)
                    
                    separator
                    
                    // TODO: 리뷰 없을 때 empty view
                    VStack(spacing: 33) {
                        PhotoReviewView()
                        ReviewList(meal: viewModel.meal)
                    }
                    .padding(.top, 17)
                    .padding(.horizontal, 16)
                    .padding(.bottom, 65)
                }
            }
        .background(Color.backgroundPrimary)
        .customNavigationBar(title: viewModel.meal.nameKr)
        .navigationBarItems(leading: backButton)
        .onAppear {
            self.showSubmitButton = UserDefaults.standard.bool(forKey: "canSubmitReview")
            if !viewModel.loadedReviews {
                viewModel.mealReviews = []
                viewModel.loadReviews()
                viewModel.loadImages()
                viewModel.loadDistribution()
                viewModel.loadedReviews = true
                print(viewModel.meal)
            }
        }
    }
}

fileprivate struct ReviewList: View {
    let meal: Meal
    
    var body: some View {
        VStack(spacing: 21) {
            HStack(spacing: 0) {
                NavigationLink(destination: ReviewListView(meal, false)) {
                    Text("리뷰")
                        .customFont(font: .text18(weight: .Bold))
                        .foregroundColor(.blackColor)
                    
                    Spacer()
                }
            }
            
            VStack(spacing: 32) {
                ForEach(0..<10) { _ in
                    ReviewRow()
                }
            }
        }
    }
}

fileprivate struct PhotoReviewView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 11) {
            Text("사진 리뷰")
                .customFont(font: .text14(weight: .Bold))
                .foregroundStyle(Color.blackColor)
            
            // TODO: 실제 데이터 넣기
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8.5) {
                    ForEach(0..<3) { _ in
                        RoundedRectangle(cornerRadius: 10)
                            .frame(width: 120, height: 120)
                            .foregroundColor(Color.gray200)
                    }
                }
            }
        }
    }
}

private extension MealInfoView {
    var separator: some View {
        Color.gray100
            .frame(height: 10)
            .frame(maxWidth: .infinity)
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
            
            // TODO: 키워드 리뷰 없을 때
            VStack(spacing: 6) {
                KeywordRateRow(type: .taste)
                KeywordRateRow(type: .price)
                KeywordRateRow(type: .yang)
            }
        }
    }
    
    var pictureList: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ThumbnailImage(viewModel.images[0])
                if viewModel.images.count >= 2 {
                    ThumbnailImage(viewModel.images[1])
                }
                if viewModel.images.indices.contains(2) {
                    NavigationLink(
                        destination: ReviewListView(viewModel.meal, true),
                        label: {
                            ZStack {
                                RemoteImage(url: viewModel.images[2])
                                    .frame(width: 120, height: 120)
                                    .clipped()
                                
                                Text(viewModel.totalImageCount-3 > 0 ? "+\n\(viewModel.totalImageCount-3)건 더 보기" : "+\n더 보기")
                                    .foregroundColor(.whiteColor)
                                    .font(.custom("NanumSquareOTFB", size: 12))
                                    .multilineTextAlignment(.center)
                            }
                            .background(Color.backgroundPrimary)
                            .opacity(0.5)
                            .cornerRadius(8)
                        })
                }
                Spacer()
            }
        }
        .padding(.leading, 16)
    }
    
    var reviewList: some View {
        VStack {
            ForEach(viewModel.mealReviews, id: \.id) { review in
                ReviewCell(review, false)
                    .padding(EdgeInsets(top: 12, leading: 8, bottom: 0, trailing: 0))
                    .listRowInsets(EdgeInsets())
                    .background(Color.backgroundPrimary)
            }
            if viewModel.hasMorePages {
                NavigationLink(destination: ReviewListView(viewModel.meal, false)) {
                    HStack(alignment: .center) {
                        Spacer()
                        
                        Text("리뷰 더 보기")
                            .font(.custom("NanumSquareOTFB", size: 13))
                            .foregroundColor(lightGrayColor)
                        
                        Image("Arrow")
                            .resizable()
                            .frame(width: 7.5, height: 12)
                            .padding(.trailing, 8)
                            .padding(.bottom, 2)
                    }
                    .padding(EdgeInsets(top: 16, leading: 0, bottom: 10, trailing: 16))
                }
            }
        }
        .padding(.bottom, 30)
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
}

private struct MealInfoPreview {
    static var previews: some View {
        let meal = Meal()
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
