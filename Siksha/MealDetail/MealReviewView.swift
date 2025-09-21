//
//  RatingView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/05.
//

import SwiftUI


private extension MealReviewView {
    var starSection: some View {
        HStack {
            Spacer()
            
            VStack(alignment: .center) {
                HStack(spacing: 0) {
                    Text("\(viewModel.meal?.nameKr ?? "")")
                        .customFont(font: .text20(weight: .ExtraBold))
//                        .font(.custom("NanumSquareOTFB", size: 22))
                        .foregroundColor(Color.blackColor)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Text("\((viewModel.meal?.nameKr ?? "").inspectFinalConsonant() == .hasConsonant ? "은" : "는") 어땠나요?")
                        .customFont(font: .text20(weight: .Bold))
                        .foregroundColor(Color.gray700)
                }
                .padding(.top, 24)
                
                Text("별점을 선택해주세요.")
                    .customFont(font: .text14(weight: .Bold))
                    .foregroundStyle(Color.gray700)
                    .padding(.top, 24)
                
                HStack(spacing: 3) {
                    ForEach(0..<5) { _ in
                        Image("Star")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 28, height: 25)
                            .foregroundStyle(Color.gray200)
                    }
                }
//                RatingStar($viewModel.scoreToSubmit, size: 35, spacing: 5.5)
//                    .gesture(
//                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
//                            .updating($score) { (value, state, transcation) in
//                                let xvalue = max(0, value.location.x)
//                                state = Int(xvalue / 50.0)+1
//                                viewModel.scoreToSubmit = min(Double(state), 5)
//                            }
//                    )
                
                // score
                Text("\(String(Int(viewModel.scoreToSubmit)))")
                    .font(.custom("NanumSquareOTFB", size: 20))
                    .foregroundColor(darkFontColor)
                    .padding(.top, 7)
                                
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 20, leading: 28, bottom: 20, trailing: 28))
    }
    
    var commentSection: some View {
        VStack(spacing: 0) {
            HStack {
                Image("Comment-new")
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 21, height: 21)
                    .foregroundStyle(Color.blackColor)
                
                HStack(spacing: 1) {
                    Text("식단 한 줄 평을 함께 남겨보세요!")
                        .customFont(font: .text18(weight: .ExtraBold))
                        .foregroundStyle(Color.blackColor)
                    
                    Text("(선택)")
                        .customFont(font: .text12(weight: .Bold))
                        .foregroundStyle(Color.gray700)
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding([.leading, .trailing], 16)
            
            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $viewModel.commentToSubmit)
                    .font(.system(size: 14))
                    .foregroundColor(viewModel.commentRecommended ? Color.gray600 : Color.blackColor)
                    .frame(height: 148)
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                    .scrollContentBackground(.hidden)
                    .background(
                        Color.gray50
                    )
                    .cornerRadius(10)

                    .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                        if viewModel.commentRecommended {
                            viewModel.commentRecommended = false
                        }
                    }
                    
                HStack {
                    Spacer()
                    Text("\(viewModel.commentToSubmit.count)자 / 150자")
                        .font(.custom("NanumSquareOTFL", size: 11))
                        .foregroundColor(fontColor)
                }
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 12, trailing: 13))
            }
            .padding(EdgeInsets(top: 11, leading: 16, bottom: 0, trailing: 16))
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
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
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
            .customFont(font: .text13(weight: .Regular))
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
    @State var selectedIndex: Int? = nil
    var selections: [String] {
        type.selects
    }
    
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
            
            HStack(spacing: 6) {
                KeywordCell(text: selections[0])
                    .onTapGesture {
                        selectedIndex = 0
                    }
                KeywordCell(text: selections[1])
                    .onTapGesture {
                        selectedIndex = 1
                    }
                KeywordCell(text: selections[2])
                    .onTapGesture {
                        selectedIndex = 2
                    }
            }
            
            HStack(spacing: 6) {
                KeywordCell(text: selections[3])
                    .onTapGesture {
                        selectedIndex = 3
                    }
                KeywordCell(text: selections[4])
                    .onTapGesture {
                        selectedIndex = 4
                    }
            }
            
        }
    }
}

struct MealReviewView: View {
    private let darkFontColor = Color.blackColor
    private let fontColor = Color.gray700
    private let orangeColor = Color.orange500

    @Environment(\.menuViewModel) var menuViewModel: MenuViewModel?
    @Environment(\.viewController) private var viewControllerHolder: UIViewController?
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @GestureState var score: Int = 0

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
        GeometryReader { geometry in
            VStack(alignment: .center, spacing: 0) {
                ScrollView {
                    starSection
                    
                    Color.gray100
                        .frame(height: 10)
                        .frame(maxWidth: .infinity)
                    
                    VStack(alignment: .leading, spacing: 0) {
                        
                        HStack(spacing: 1) {
                            Text("어떤 점이 얼마나 좋았나요?")
                                .customFont(font: .text18(weight: .ExtraBold))
                                .foregroundStyle(Color.blackColor)
                            
                            Text("(필수)")
                                .customFont(font: .text12(weight: .Bold))
                                .foregroundStyle(Color.gray700)
                            
                            Spacer()
                        }
                        .padding(16)
                        
                        VStack(spacing: 22) {
                            KeywordSelectionView(type: .taste)
                            KeywordSelectionView(type: .price)
                            KeywordSelectionView(type: .yang)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.bottom, 30)
                    
                    commentSection
                    
//                    imageSection
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
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Preview


struct MealReviewView_Previews: PreviewProvider {
    static var previews: some View {
        let meal = Meal()
        meal.nameKr = "올리브스테이크"

        return MealReviewView(meal, mealInfoViewModel: MealInfoViewModel(meal: meal))
    }
}
