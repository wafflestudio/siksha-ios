//
//  RatingView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/05.
//

import SwiftUI

struct MealReviewView: View {
    private let darkFontColor = Color.blackColor
    private let fontColor = Color.gray700
    private let orangeColor = Color.orange500
    
    @Environment(\.menuViewModel) var menuViewModel: MenuViewModel?
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var viewModel: MealReviewViewModel = MealReviewViewModel()
    @ObservedObject var mealInfoViewModel: MealInfoViewModel
    
    @State private var isShowingPhotoLibrary = false
    @State private var addedImages = [UIImage]()
    
    let meal: Meal
    
    init(_ meal: Meal, mealInfoViewModel: MealInfoViewModel) {
        self.meal = meal
        self.mealInfoViewModel = mealInfoViewModel
        UITextView.appearance().backgroundColor = .clear
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                starSection
                
                Color.gray100
                    .frame(height: 10)
                    .frame(maxWidth: .infinity)
                
                Spacer().frame(height: 26)
                
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 5) {
                        Text("어떤 점이 얼마나 좋았나요?")
                            .customFont(font: .text18(weight: .ExtraBold))
                            .foregroundStyle(Color.blackColor)
                        
                        Text("(필수)")
                            .customFont(font: .text12(weight: .Bold))
                            .foregroundStyle(Color.gray700)
                        
                        Spacer()
                    }
                    
                    Spacer().frame(height: 18)
                    
                    VStack(spacing: 22) {
                        KeywordSelectionView(type: .taste, viewModel: viewModel)
                        KeywordSelectionView(type: .price, viewModel: viewModel)
                        KeywordSelectionView(type: .yang, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 35)
                
                commentSection
                
                Spacer().frame(height: 66)
            }
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            
            Spacer()
            
            submitButton
        }
        .customNavigationBar(title: "나의 평가 남기기")
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.meal = self.meal
        }
        .alert(isPresented: $viewModel.showAlert, content: {
            Alert(title: Text("나의 평가 남기기"), message: alertMessage, dismissButton: alertButton)
        })
        .ignoresSafeArea(.keyboard)
    }
}


private extension MealReviewView {
    var starSection: some View {
        VStack(alignment: .center, spacing: 0) {
            HStack(spacing: 0) {
                Text("\(viewModel.meal?.nameKr ?? "")")
                    .customFont(font: .text20(weight: .ExtraBold))
                    .foregroundColor(Color.blackColor)
                    .lineLimit(1)
                    .truncationMode(.tail)
                Text("\((viewModel.meal?.nameKr ?? "").inspectFinalConsonant() == .hasConsonant ? "은" : "는") 어땠나요?")
                    .customFont(font: .text20(weight: .Bold))
                    .foregroundColor(Color.gray700)
            }
            
            Spacer().frame(height: 24)
            
            Text("별점을 선택해주세요.")
                .customFont(font: .text14(weight: .Bold))
                .foregroundStyle(Color.gray700)
            
            Spacer().frame(height: 9)
            
            StarRateView(rate: $viewModel.scoreToSubmit, spacing: 3)
                .frame(height: 25)
            
            Spacer().frame(height: 9)
            
            Text("\(String(viewModel.scoreString))")
                .customFont(font: .text20(weight: .Bold))
                .foregroundColor(Color.blackColor)
        }
        .padding(.horizontal, 15.5)
        .padding(EdgeInsets(top: 41, leading: 0, bottom: 19, trailing: 0))
    }
    
    var commentSection: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image("TextBubble")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 21.6, height: 21.6)
                    .foregroundStyle(Color.blackColor)
                
                Spacer().frame(width: 14.6)
                
                HStack(spacing: 4.8) {
                    Text("식단 한 줄 평을 함께 남겨보세요!")
                        .customFont(font: .text18(weight: .ExtraBold))
                        .foregroundStyle(Color.blackColor)
                    
                    Text("(선택)")
                        .customFont(font: .text12(weight: .Bold))
                        .foregroundStyle(Color.gray700)
                }
                
                Spacer(minLength: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4.8)
            
            Spacer().frame(height: 15)
            
            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $viewModel.commentToSubmit)
                    .customFont(font: .text14(weight: .Regular))
                    .foregroundColor(Color.blackColor)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 12)
                    .frame(height: 148)
                    .scrollContentBackground(.hidden)
                    .background(
                        Color.gray50
                    )
                    .cornerRadius(8)
                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                        if viewModel.commentRecommended {
                            viewModel.commentRecommended = false
                        }
                    }
                    
                HStack(spacing: 0) {
                    Spacer()
                    Text("\(viewModel.commentToSubmit.count)자 / 150자")
                        .customFont(font: .text11(weight: .Regular))
                        .foregroundColor(Color.gray700)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 12))
            }
            .padding(.horizontal, 16)
        }
    }
    
    var imageSection: some View {
        VStack(spacing: 8) {
            ScrollView (.horizontal) {
                HStack {
                    ForEach(addedImages, id: \.self) { image in
                        ZStack(alignment: .topTrailing) {
                            Image(uiImage: image)
                                .resizable()
                                .renderingMode(.original)
                                .scaledToFill()
                                .frame(width: 80, height: 80)
                                .cornerRadius(8)
                                .clipped()
                                .padding([.top, .trailing], 5)
                            
                            Button(action: {
                                if self.addedImages.contains(image) {
                                    self.addedImages.removeAll(where: { $0 == image })
                                }
                            }) {
                                ZStack {
                                    Image("imageXButton")
                                        .resizable()
                                        .renderingMode(.original)
                                        .frame(width: 16, height: 16)
                                }
                                .padding(EdgeInsets(top: 0, leading: 8, bottom: 8, trailing: 0))
                            }
                        }
                    }
                }
            }
            .padding(EdgeInsets(top: 0, leading: 28, bottom: 0, trailing: 28))
            
            HStack {
                Spacer()
                    .frame(width: 28)
                
                Button(action: {
                    self.isShowingPhotoLibrary = true
                }) {
                    Image("reviewSummit")
                        .frame(width: 134, height: 32)
                }
                .sheet(isPresented: $isShowingPhotoLibrary) {
                    ImagePickerCoordinatorView(selectedImages: $addedImages, maxSelection: 5)
                }
                
                Spacer()
            }
        }
    }
    
    var submitButton: some View {
        Button(action: {
            if addedImages.count > 0 {
                viewModel.submitReviewImages(images: addedImages)
            } else {
                viewModel.submitReview()

            }
        }) {
            ZStack(alignment: .top) {
                if viewModel.canSubmit {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.orange500)
                        .frame(width: 343, height: 56)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.gray600)
                        .frame(width: 343, height: 56)
                }
                
                Text("평가 등록")
                    .customFont(font: .text18(weight: .ExtraBold))
                    .foregroundColor(Color.textButton)
                    .padding(.top, 15)
            }
        }
        .padding(.bottom, 20)
        .disabled(!viewModel.canSubmit)
    }

    var alertMessage: Text {
        var message = ""
        if viewModel.postReviewSucceeded {
            message = "평가가 등록되었습니다."
        } else {
            if let error = viewModel.errorCode {
                message = error.message
            } else {
                message = "예상치 못한 오류입니다. 다시 시도해주세요."
            }
        }
        return Text(message)
    }
    
    var alertButton: Alert.Button {
        var action: (() -> Void)? = nil
        if viewModel.postReviewSucceeded {
            action = {
                mealInfoViewModel.mealReviews = []
                mealInfoViewModel.loadReviews()
                mealInfoViewModel.loadImages()
                mealInfoViewModel.loadDistribution()
                menuViewModel?.pageViewReload = true
                presentationMode.wrappedValue.dismiss()
            }
        } else {
            if let _ = viewModel.errorCode {
                action = {
                    presentationMode.wrappedValue.dismiss()
                }
            } else {
                action = {}
            }
        }
        return Alert.Button.default(Text("확인"), action: action)
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
                .foregroundColor(Color.white)
        }
    }
}

// MARK: - Rating View

struct KeywordCell: View {
    var text: String
    var isSelected: Bool = false
    
    var body: some View {
        Text(text)
            .customFont(font: .text13(weight: isSelected ? .Bold : .Regular))
            .foregroundStyle(isSelected ? Color.orange500 : Color.gray800)
            .padding(.vertical, 5)
            .padding(.horizontal, 11)
            .background {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.orange500 : Color.gray200, lineWidth: 1)
            }
    }
}

struct KeywordSelectionView: View {
    var type: KeywordRateType
    @ObservedObject var viewModel: MealReviewViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 4) {
                Image(type.imageString)
                    .resizable()
                    .frame(width: 16, height: 16)
                    .padding(3)
                Text(type.title)
                    .customFont(font: .text14(weight: .Bold))
                    .foregroundStyle(Color.blackColor)
            }
            
            KeywordCellContainerView(type: type, viewModel: viewModel)
        }
    }
}

private struct KeywordCellContainerView: View {
    @State var totalHeight: CGFloat = .zero
    let verticalSpacing: CGFloat = 6
    let horizontalSpacing: CGFloat = 6
    
    let type: KeywordRateType
    @ObservedObject var viewModel: MealReviewViewModel
    
    private var items: [String] {
        type.selects
    }
    
    public var body: some View {
        var width = CGFloat.zero
        var height = CGFloat.zero
        
        GeometryReader { geo in
            ZStack(alignment: .topLeading) {
                ForEach(0..<5) { index in
                    KeywordCell(text: items[index], isSelected: viewModel.selectedKeywords[type] == items[index])
                        .onTapGesture { _ in
                            viewModel.selectedKeywords[type] = items[index]
                        }
                        .alignmentGuide(.leading) { view in
                            if abs(width - view.width) > geo.size.width {
                                width = 0
                                height -= view.height
                                height -= verticalSpacing
                            }
                            let result = width
                            
                            if items[index] == items.last {
                                width = 0
                            } else {
                                width -= view.width
                                width -= horizontalSpacing
                            }
                            
                            return result
                        }
                        .alignmentGuide(.top) { _ in
                            let result = height
                            
                            if items[index] == items.last {
                                height = 0
                            }
                            return result
                        }
                }
            }
            .background(
                GeometryReader { geometry in
                    Color.clear
                        .onAppear {
                            self.totalHeight = geometry.size.height
                        }
                }
            )
        }
        .frame(height: totalHeight)
    }
}

// MARK: - Preview


struct MealReviewPreview {
    static var previews: some View {
        let meal = Meal()
        meal.nameKr = "올리브스테이크"
        
        return MealReviewView(meal, mealInfoViewModel: MealInfoViewModel(meal: meal))
    }
}

#Preview {
    NavigationView {
        MealReviewPreview.previews
    }
}
