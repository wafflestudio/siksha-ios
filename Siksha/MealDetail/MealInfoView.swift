//
//  MealInfoView.swift
//  Siksha
//
//  Created by 박종석 on 2021/03/06.
//

import SwiftUI

enum KeywordRateType {
    case taste
    case price
    case yang
    
    var imageString: String {
        switch self {
        case .taste:
            return "KeywordTaste"
        case .price:
            return "KeywordMoney"
        case .yang:
            return "KeywordYang"
        }
    }
    
    var description: String {
        switch self {
        case .taste:
            return "또 먹고 싶어요"
        case .price:
            return "가성비 좋아요"
        case .yang:
            return "알찬 편이에요"
        }
    }
    
    var tempCnt: Int {
        switch self {
        case .taste:
            22
        case .price:
            10
        case .yang:
            17
        }
    }
    
    var title: String {
        switch self {
        case .taste:
            return "맛"
        case .price:
            return "가격"
        case .yang:
            return "음식 구성"
        }
    }
    
    var selects: [String] {
        switch self {
        case .taste:
            ["또 먹고 싶어요", "생각보다 맛있어요", "무난해요", "아쉬운 맛이에요", "별로에요"]
        case .price:
            ["혜자스러워요", "가성비 좋아요", "합리적이에요", "약간 비싸요", "너무 비싸요"]
        case .yang:
            ["조화로워요", "알찬 편이에요", "기본적이에요", "다소 단조로워요", "너무 빈약해요"]
        }
    }
}

struct KeywordRateRow: View {
    var type: KeywordRateType
    
    var body: some View {
        HStack(spacing: 0) {
            Image(type.imageString)
                .resizable()
                .scaledToFit()
                .frame(width: 16, height: 16)
                .padding(.trailing, 9.5)
                .padding(.leading, 18)
            
            Text(type.description)
                .customFont(font: .text13(weight: .Bold))
                .foregroundStyle(Color.gray800)
            
            Spacer()
            
            Text("\(type.tempCnt)")
                .customFont(font: .text14(weight: .ExtraBold))
                .foregroundStyle(Color.orange500)
                .padding(.trailing, 19)
        }
        .frame(width: 217, height: 36)
        .background {
            ZStack(alignment: .leading) {
                Color.gray100
                
                Group {
                    if type == .price {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orangeTint)
                            .frame(width: 106)
                    } else if type == .yang {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.orangeTint)
                            .frame(width: 156)
                    } else {
                        Color.orangeTint
                    }
                }
                .background{ Color.white }
                .cornerRadius(8)
            }
        }
        .cornerRadius(8)
    }
}

private extension MealInfoView {
    
    var scoreSummary: some View {
        VStack(spacing: 0) {
            HStack (alignment: .center, spacing: 12) {
                VStack(alignment: .center, spacing: 0) {
                    Text("\(String(format: "%.1f", viewModel.meal.score))")
                        .customFont(font: .text32(weight: .Bold))
                        .foregroundColor(Color.blackColor)
                    
                    RatingStar(.constant(viewModel.meal.score), size: 12, spacing: 1)
                    
                    Spacer().frame(height: 10)
                    
                    Text("후기 47개")
                        .customFont(font: .text14(weight: .Regular))
                        .foregroundStyle(Color.blackColor)
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 20)
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.gray200, lineWidth: 1)
                }
                
                VStack(spacing: 6) {
                    KeywordRateRow(type: .taste)
                    KeywordRateRow(type: .price)
                    KeywordRateRow(type: .yang)
                }
                            
//                VStack(alignment: .leading) {
//                    HStack(spacing: 0) {
//                        Text("총 ")
//                            .font(.custom("NanumSquareOTFB", size: 12))
//                            .foregroundColor(lightGrayColor)
//                        Text("\(viewModel.meal.reviewCnt)명")
//                            .font(.custom("NanumSquareOTFB", size: 12))
//                            .foregroundColor(orangeColor)
//                        Text("이 평가했어요!")
//                            .font(.custom("NanumSquareOTFB", size: 12))
//                            .foregroundColor(lightGrayColor)
//                    }
//                                    
//                    HorizontalGraph(viewModel.scoreDistribution)
//                        .frame(width: 200, alignment: .leading)
//                }
//                .padding(.leading, 20)
//                
//                Spacer()
            }
            .padding(EdgeInsets(top: 20, leading: 0, bottom: 16, trailing: 0))
            
//            if showSubmitButton {
//                NavigationLink(
//                    destination: MealReviewView(viewModel.meal, mealInfoViewModel: viewModel)
//                        .environment(\.menuViewModel, menuViewModel),
//                    label: {
//                        Image("RateButton-new")
//                            .resizable()
//                            .renderingMode(.original)
//                            .frame(width: 200, height: 32)
//                    })
//            }
            
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
                            .padding(.horizontal, 20)
                            .background(Color.orange500)
                            .cornerRadius(50)
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
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                .foregroundColor(.white)
        }
    }
}

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
        UITableView.appearance().separatorStyle = .none
        
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
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
                    
                    HStack {
                        Color.gray100
                            .frame(height: 10)
                            .frame(maxWidth: .infinity)
                    }
                    
                    scoreSummary
                        .padding(.vertical, 20)
                    
                    Color.gray100
                        .frame(height: 10)
                        .frame(maxWidth: .infinity)
                        .padding(.top, 10)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("사진 리뷰")
                            .customFont(font: .text14(weight: .Bold))
                            .foregroundStyle(Color.blackColor)
                        
                        ScrollView {
                            HStack(spacing: 8.5) {
                                ForEach(0..<3) { _ in
                                    RoundedRectangle(cornerRadius: 10)
                                        .frame(width: 120, height: 120)
                                        .foregroundColor(Color.gray200)
                                }
                            }
                        }
                    }
                    .padding(.top, 17)
                    .padding(.bottom, 15)
                    .padding(.horizontal, 16)
                    
                    HStack {
                        NavigationLink(
                            destination: EmptyView(),
                            label: {})
                        NavigationLink(destination: ReviewListView(viewModel.meal, false)) {
                            Text("리뷰")
                                .font(.custom("NanumSquareOTFB", size: 18))
                                .foregroundColor(.blackColor)
                            
                            Spacer()
                            
//                            Image("Arrow")
//                                .resizable()
//                                .frame(width: 7.5, height: 12)
                        }
                    }
                    .padding(EdgeInsets(top: 10, leading: 16, bottom: 21, trailing: 16))
                    VStack(spacing: 32) {
                        ForEach(0..<10) { _ in
                            ReviewRow()
                                .padding(.horizontal, 16)
                        }
                    }
                    
//                    if viewModel.mealReviews.count > 0 {
//                        reviewList
//                    } else {
//                        Text("평가가 없습니다.")
//                            .font(.custom("NanumSquareOTFB", size: 13))
//                            .foregroundColor(lightGrayColor)
//                            .padding(.top, 20)
//                    }
                }
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
        return MealInfoView(viewModel: MealInfoViewModel(meal: meal))
    }
}
