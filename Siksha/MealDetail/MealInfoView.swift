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
                Spacer()
                
                VStack(alignment: .center, spacing: 10) {
                    Text("\(String(format: "%.1f", viewModel.meal.score))")
                        .font(.custom("NanumSquareOTFB", size: 32))
                        .foregroundColor(.black)
                    
                    RatingStar(.constant(viewModel.meal.score), size: 17, spacing: 0.8)
                }
                            
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
                                    
                    HorizontalGraph([10, 20, 30, 40, 50])
                        .frame(width: 200, alignment: .leading)
                }
                .padding(.leading, 20)
                
                Spacer()
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 0, trailing: 0))
            
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
                        .padding(.top, 18)
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
                        .padding(EdgeInsets(top: 18, leading: 0, bottom: 24, trailing: 0))
                }
            }
        }
        
    }
    
    var pictureList: some View {
        HStack {
            ClickableImage(viewModel.images[0])
            if viewModel.images.count >= 2 {
                ClickableImage(viewModel.images[1])
            }
            if viewModel.images.indices.contains(2) {
                NavigationLink(
                    destination: ReviewView(viewModel.meal, true),
                    label: {
                        ZStack {
                            RemoteImage(url: viewModel.images[2])
                                .frame(width: 120, height: 120)
                            
                            Text("+\n\(viewModel.images.count)건 더 보기")
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
        .padding([.leading, .trailing], 16)
        
    }
    
    var reviewList: some View {
        List {
            ForEach(viewModel.mealReviews, id: \.id) { review in
                ReviewCell(review, false)
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
    }
    
}

struct MealInfoView: View {
    private let darkFontColor = Color.init("DarkFontColor")
    private let lightGrayColor = Color.init("LightGrayColor")
    private let orangeColor = Color.init("MainThemeColor")
    @ObservedObject var viewModel: MealInfoViewModel
    @State var showSubmitButton: Bool = true
    @State var showDetailImage: Bool = false
    
    init(meal: Meal) {
        UITableView.appearance().separatorStyle = .none
        
        self.viewModel = MealInfoViewModel(meal)
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                NavigationBar(title: "리뷰", showBack: true)
                
                ScrollView {
                    Text(viewModel.meal.nameKr)
                        .font(.custom("NanumSquareOTFB", size: 20))
                        .foregroundColor(.black)
                        .lineLimit(1)
                        .padding(EdgeInsets(top: 18, leading: 16, bottom: 0, trailing: 16))
                    
                    scoreSummary
                    
                    Rectangle()
                        .fill(Color.init(UIColor(named: "AppBackgroundColor")!))
                        .frame(height: 10)
                        .edgesIgnoringSafeArea(.horizontal)
                        .padding(.top, 16)
                    
                    if viewModel.images.count > 0 {
                        NavigationLink(
                            destination: ReviewView(viewModel.meal, true),
                            label: {
                                HStack {
                                    Text("사진 리뷰 모아보기")
                                        .font(.custom("NanumSquareOTFB", size: 16))
                                        .foregroundColor(darkFontColor)
                                    
                                    Spacer()
                                    
                                    Image("Arrow")
                                        .padding(.trailing, 16)
                                    
                                }
                                
                            })
                            .navigationViewStyle(StackNavigationViewStyle())
                            .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 0))
                       
                        pictureList
                            .padding(.top, 17)

                    }
                    
                    HStack {
                        NavigationLink(
                            destination: ReviewView(viewModel.meal, false),
                            label: {
                                Text("리뷰")
                                    .font(.custom("NanumSquareOTFB", size: 16))
                                    .foregroundColor(darkFontColor)
                                    .padding(.leading, 20)
                                
                                Spacer()
                                
                                Image("Arrow")
                                    .padding(.trailing, 16)
                            })
                    }
                    .padding(.top, 20)
                    
                    if viewModel.mealReviews.count > 0 {
                        reviewList
                            .frame(width: geometry.size.width - 5, height: geometry.size.height - 200)
                    } else {
                        Text("평가가 없습니다.")
                            .font(.custom("NanumSquareOTFB", size: 13))
                            .foregroundColor(lightGrayColor)
                            .padding(.top, 20)
                    }
                    
                    Spacer()
                }
                
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .onAppear {
                self.showSubmitButton = UserDefaults.standard.bool(forKey: "canSubmitReview")
                viewModel.mealReviews = []
                viewModel.currentPage = 1
                viewModel.loadMoreReviewsIfNeeded(currentItem: nil)
                viewModel.loadMoreImagesIfNeeded(currentItem: nil)
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
