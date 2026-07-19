//
//  RatingView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/05.
//

import PhotosUI
import SwiftUI

struct MealReviewView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: MealReviewViewModel
    @ObservedObject var mealInfoViewModel: MealInfoViewModel
    @State private var isShowingPhotoLibrary = false

    let meal: MenuItemDisplayModel
    let existingReview: RestaurantReview?

    // 새 리뷰 등록 생성자
    init(_ meal: MenuItemDisplayModel, mealInfoViewModel: MealInfoViewModel) {
        self.meal = meal
        self.mealInfoViewModel = mealInfoViewModel
        self.existingReview = nil

        _viewModel = StateObject(
            wrappedValue: MealReviewViewModel(
                meal: meal,
                fetchReviewCommentRecommendationUseCase: AppContainer.shared.useCases
                    .fetchReviewCommentRecommendationUseCase,
                submitMealReviewUseCase: AppContainer.shared.useCases.submitMealReviewUseCase,
                editMealReviewUseCase: AppContainer.shared.useCases.editMealReviewUseCase
            ))
        UITextView.appearance().backgroundColor = .clear
    }

    // 리뷰 수정 생성자
    init(_ meal: MenuItemDisplayModel, mealInfoViewModel: MealInfoViewModel, editingReview: RestaurantReview) {
        self.meal = meal
        self.mealInfoViewModel = mealInfoViewModel
        self.existingReview = editingReview

        let vm = MealReviewViewModel(
            meal: meal,
            fetchReviewCommentRecommendationUseCase: AppContainer.shared.useCases
                .fetchReviewCommentRecommendationUseCase,
            submitMealReviewUseCase: AppContainer.shared.useCases.submitMealReviewUseCase,
            editMealReviewUseCase: AppContainer.shared.useCases.editMealReviewUseCase
        )
        vm.loadExistingReview(editingReview)
        _viewModel = StateObject(wrappedValue: vm)

        UITextView.appearance().backgroundColor = .clear
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                MenuRatingHeaderView(menuName: meal.nameKr, score: $viewModel.scoreToSubmit)
                separator
                Spacer().frame(height: 26)
                KeywordSectionView(viewModel: viewModel)
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
        .background(Color.backgroundPrimary)
        .customNavigationBar(title: isEditMode ? "나의 평가 수정하기" : "나의 평가 남기기")
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.meal = self.meal
        }
        .alert(
            isPresented: $viewModel.showAlert,
            content: {
                Alert(
                    title: Text(isEditMode ? "나의 평가 수정하기" : "나의 평가 남기기"), message: alertMessage,
                    dismissButton: alertButton)
            }
        )
        .ignoresSafeArea(.keyboard)
    }

    private var isEditMode: Bool {
        existingReview != nil
    }
}

private extension MealReviewView {
    private var separator: some View {
        Color.gray100
            .frame(height: 10)
            .frame(maxWidth: .infinity)
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
                        .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification))
                    { _ in
                        if viewModel.commentToSubmit.isEmpty {
                            viewModel.scoreToSubmit = viewModel.scoreToSubmit
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
        Button {
            if isEditMode {
                viewModel.editReview(reviewId: existingReview!.id)
            } else {
                if viewModel.selectedImages.count > 0 {
                    viewModel.submitReviewImages(images: viewModel.selectedImages)
                } else {
                    viewModel.submitReview()
                }
            }
        } label: {
            ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 8)
                    .fill(viewModel.canSubmit ? Color.orange500 : Color.gray600)
                    .frame(height: 56)
                    .frame(maxWidth: .infinity)

                Text(isEditMode ? "평가 수정" : "평가 등록")
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
            message = isEditMode ? "평가가 수정되었습니다." : "평가가 등록되었습니다."
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
                if let meal = viewModel.meal {
                    mealInfoViewModel.meal = meal
                }
                mealInfoViewModel.updateMealFromId()
                mealInfoViewModel.mealReviews = []
                mealInfoViewModel.loadReviews()
                mealInfoViewModel.loadImages()
                mealInfoViewModel.loadDistribution()
                dismiss()
            }
        } else {
            if viewModel.errorCode != nil {
                action = {
                    dismiss()
                }
            } else {
                action = {}
            }
        }
        return Alert.Button.default(Text("확인"), action: action)
    }

    var backButton: some View {
        Button(action: {
            dismiss()
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

@MainActor
struct MealReviewPreview {
    static var previews: some View {
        let meal = MenuItemDisplayModel(
            id: 0,
            code: "",
            nameKr: "올리브스테이크",
            nameEn: "",
            price: 0,
            score: 0,
            reviewCount: 0,
            isLiked: false,
            likeCount: 0,
            imageURLStrings: []
        )

        return MealReviewView(
            meal,
            mealInfoViewModel: MealInfoViewModel(
                meal: meal,
                fetchMenuUseCase: AppContainer.shared.useCases.fetchMenuUseCase,
                fetchMealReviewsUseCase: AppContainer.shared.useCases.fetchMealReviewsUseCase,
                fetchMealImageReviewsUseCase: AppContainer.shared.useCases.fetchMealImageReviewsUseCase,
                fetchMealReviewScoreDistributionUseCase: AppContainer.shared.useCases
                    .fetchMealReviewScoreDistributionUseCase,
                fetchMealReviewKeywordDistributionUseCase: AppContainer.shared.useCases
                    .fetchMealReviewKeywordDistributionUseCase,
                updateMenuLikeUseCase: AppContainer.shared.useCases.updateMenuLikeUseCase
            )
        )
    }
}

#Preview {
    NavigationView {
        MealReviewPreview.previews
    }
}
