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
                    Text("'\(viewModel.meal?.nameKr ?? "")")
                        .font(.custom("NanumSquareOTFB", size: 22))
                        .foregroundColor(darkFontColor)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Text("'")
                        .font(.custom("NanumSquareOTFB", size: 22))
                        .foregroundColor(darkFontColor)
                    Text("\((viewModel.meal?.nameKr ?? "").inspectFinalConsonant() == .hasConsonant ? "은" : "는") 어땠나요?")
                        .font(.custom("NanumSquareOTFB", size: 22))
                        .foregroundColor(Color(red: 112 / 255, green: 112 / 255, blue: 112 / 255))
                }
                .padding(.top, 24)
                
                Text("별점을 선택해주세요.")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(Color(red: 112 / 255, green: 112 / 255, blue: 112 / 255))
                    .padding(.top, 26)
                
                RatingStar($viewModel.scoreToSubmit, size: 35, spacing: 5.5)
                    .gesture(
                        DragGesture(minimumDistance: 0, coordinateSpace: .local)
                            .updating($score) { (value, state, transcation) in
                                state = Int(value.location.x / 50.0)+1
                                viewModel.scoreToSubmit = max(0, min(Double(state), 5))
                            }
                    )
                
                // score
                Text("\(String(Int(viewModel.scoreToSubmit)))")
                    .font(.custom("NanumSquareOTFB", size: 20))
                    .foregroundColor(darkFontColor)
                    .padding(.top, 7)
                                
            }
            
            Spacer()
        }
        .padding(EdgeInsets(top: 20, leading: 28, bottom: 48, trailing: 28))
    }
    
    var commentSection: some View {
        VStack(spacing: 0) {
            HStack {
                Image("Comment-new")
                    .resizable()
                    .frame(width: 17, height: 16)
                
                Text("식단 한 줄 평을 함께 남겨보세요!")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(fontColor)
                
                Spacer()
            }
            .padding([.leading, .trailing], 36)
            
            ZStack(alignment: .bottomTrailing) {
                TextEditor(text: $viewModel.commentToSubmit)
                    .font(.system(size: 14))
                    .foregroundColor(viewModel.commentRecommended ? Color.gray : Color.black)
                    .frame(height: 148)
                    .padding(EdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8))
                    .background(
                        Color.init("AppBackgroundColor")
                            .cornerRadius(10)
                    )
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
            .padding(EdgeInsets(top: 11, leading: 28, bottom: 0, trailing: 28))
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
                        .fill(Color.init("main"))
                        .frame(width: 343, height: 56)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.init("LightGrayColor"))
                        .frame(width: 343, height: 56)
                }
                
                Text("평가 등록")
                    .font(.custom("NanumSquareOTFB", size: 20))
                    .foregroundColor(.white)
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
                favViewModel?.pageViewReload = true
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
                .frame(width: 10, height: 16)
        }
    }
}

// MARK: - Rating View

struct MealReviewView: View {
    private let darkFontColor = Color("DarkFontColor")
    private let fontColor = Color("DefaultFontColor")
    private let orangeColor = Color.init("main")

    @Environment(\.favoriteViewModel) var favViewModel: FavoriteViewModel?
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
                    
                    commentSection
                    
                    imageSection
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


//struct MealReviewView_Previews: PreviewProvider {
//    static var previews: some View {
//        let meal = Meal()
//        meal.nameKr = "올리브스테이크"
//
//        return MealReviewView(meal, mealInfoViewModel: MealInfoViewModel(meal))
//    }
//}
