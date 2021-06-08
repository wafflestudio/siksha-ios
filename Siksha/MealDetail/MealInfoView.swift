//
//  MealInfoView.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/06.
//

import SwiftUI

private extension MealInfoView {
    var scoreSummary: some View {
        VStack(spacing: 0) {
            HStack (alignment: .center) {
                VStack(alignment: .center, spacing: 10) {
                    Text("\(String(format: "%.1f", viewModel.meal.score))")
                        .font(.custom("NanumSquareOTFB", size: 32))
                        .foregroundColor(.black)
                    
                    RatingStar(.constant(viewModel.meal.score), size: 17, spacing: 0.8)
                }
                .padding(.leading, 45)
                            
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Text("총 ")
                            .font(.custom("NanumSquareOTFB", size: 12))
                            .foregroundColor(lightGrayColor)
                        Text("\(viewModel.meal.reviewCnt)명")
                            .font(.custom("NanumSquareOTFB", size: 12))
                            .foregroundColor(orangeColor)
                        Text("이 평가했어요!")
                            .font(.custom("NanumSquareOTFB", size: 12))
                            .foregroundColor(lightGrayColor)
                    }
                                    
                    HorizontalGraph(viewModel.scoreDistribution)
                        .frame(width: 200, alignment: .leading)
                }
                .padding(.leading, 20)
                
                Spacer()
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 16, trailing: 0))
            
            if showSubmitButton {
                NavigationLink(
                    destination: MealReviewView(viewModel.meal, mealInfoViewModel: viewModel)
                        .environment(\.menuViewModel, menuViewModel)
                        .environment(\.favoriteViewModel, favViewModel),
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
                                
                                Text("+\n\(viewModel.totalImageCount-3)건 더 보기")
                                    .foregroundColor(.white)
                                    .font(.custom("NanumSquareOTFB", size: 12))
                                    .multilineTextAlignment(.center)
                            }
                            .background(Color.black)
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
                    .background(Color.white)
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
}

struct MealInfoView: View {
    private let darkFontColor = Color.init("DarkFontColor")
    private let lightGrayColor = Color.init("LightGrayColor")
    private let orangeColor = Color.init("MainThemeColor")
    @Environment(\.favoriteViewModel) var favViewModel: FavoriteViewModel?
    @Environment(\.menuViewModel) var menuViewModel: MenuViewModel?
    @ObservedObject var viewModel: MealInfoViewModel
    @State var showSubmitButton: Bool = true
    @State var showDetailImage: Bool = false
    
    init(meal: Meal) {
        UITableView.appearance().separatorStyle = .none
        
        self.viewModel = MealInfoViewModel(meal)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            NavigationBar(title: "리뷰", showBack: true)
            
            ScrollView {
                VStack(spacing: 0) {
                    Text(viewModel.meal.nameKr)
                        .font(.custom("NanumSquareOTFB", size: 20))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .padding(EdgeInsets(top: 20, leading: 16, bottom: 0, trailing: 16))
                    
                    scoreSummary
                    
                    Color.init("DarkBackgroundColor")
                        .frame(height: 10)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 16)
                    
                    if viewModel.images.count > 0 {
                        NavigationLink(destination: ReviewListView(viewModel.meal, true)) {
                            HStack {
                                Text("사진 리뷰 모아보기")
                                    .font(.custom("NanumSquareOTFB", size: 16))
                                    .foregroundColor(darkFontColor)
                                
                                Spacer()
                                
                                Image("Arrow")
                                    .resizable()
                                    .frame(width: 7.5, height: 12)
                            }
                        }
                        .padding(EdgeInsets(top: 16, leading: 16, bottom: 0, trailing: 16))
                        
                        pictureList
                            .padding(.top, 17)
                    }
                    
                    HStack {
                        NavigationLink(destination: ReviewListView(viewModel.meal, false)) {
                            Text("리뷰")
                                .font(.custom("NanumSquareOTFB", size: 16))
                                .foregroundColor(darkFontColor)
                            
                            Spacer()
                            
                            Image("Arrow")
                                .resizable()
                                .frame(width: 7.5, height: 12)
                        }
                    }
                    .padding(EdgeInsets(top: 20, leading: 16, bottom: 4, trailing: 16))
                    
                    if viewModel.mealReviews.count > 0 {
                        reviewList
                    } else {
                        Text("평가가 없습니다.")
                            .font(.custom("NanumSquareOTFB", size: 13))
                            .foregroundColor(lightGrayColor)
                            .padding(.top, 20)
                    }
                }
            }
        }
        .edgesIgnoringSafeArea(.top)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
        .onAppear {
            self.showSubmitButton = UserDefaults.standard.bool(forKey: "canSubmitReview")
            if !viewModel.loadedReviews {
                viewModel.mealReviews = []
                viewModel.loadReviews()
                viewModel.loadImages()
                viewModel.loadDistribution()
                viewModel.loadedReviews = true
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
