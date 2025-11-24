//
//  RatingView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/05.
//

import SwiftUI
import PhotosUI

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
                        KeywordSelectionView(type: .composition, viewModel: viewModel)
                    }
                }
                .padding(.horizontal, 16)
                
                Spacer().frame(height: 35)
                
                commentSection
                
                Spacer().frame(height: 2)
                
                PhotoAddView(viewModel: viewModel)
                    .padding(.horizontal, 16)
                
                Spacer().frame(height: 66)
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.endEditing()
            }
            
            Spacer()
            
            submitButton
                .padding(.horizontal, 16)
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
            
            ZStack(alignment: .topLeading) {
                VStack(spacing: 0) {
                    TextEditor(text: $viewModel.commentToSubmit)
                        .customFont(font: .text14(weight: .Regular))
                        .foregroundColor(Color.blackColor)
                        .accentColor(.blackColor)
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                            if viewModel.commentRecommended {
                                viewModel.commentRecommended = false
                            }
                        }
                        .onChange(of: viewModel.commentToSubmit) { comment in
                            viewModel.commentToSubmit = String(comment.prefix(150))
                        }
                    
                    HStack(spacing: 0) {
                        Spacer()
                        Text("\(viewModel.commentToSubmit.count)자 / 150자")
                            .customFont(font: .text11(weight: .Regular))
                            .foregroundColor(Color.gray700)
                    }
                    .padding(.bottom, 12)
                }
                .padding(.horizontal, 12)
                .frame(height: 148)
                .scrollContentBackground(.hidden)
                .background(
                    Color.gray50
                )
                .cornerRadius(8)
                
                if viewModel.commentToSubmit.isEmpty {
                    textEditorPlaceholder
                        .padding(.horizontal, 16)
                        .padding(.top, 12)
                }
            }
            .padding(.horizontal, 16)
        }
    }
    
    var textEditorPlaceholder: some View {
        Text("오늘의 메뉴는 어땠나요?")
            .customFont(font: .text14(weight: .Regular))
            .foregroundStyle(Color.gray600)
    }
    
    var submitButton: some View {
        Button(action: {
            if viewModel.selectedImages.count > 0 {
                viewModel.submitReviewImages(images: viewModel.selectedImages)
            } else {
                viewModel.submitReview()
            }
        }) {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(viewModel.canSubmit ? Color.orange500 : Color.gray600)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)
                
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
