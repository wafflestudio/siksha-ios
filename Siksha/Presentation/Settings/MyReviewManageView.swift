//
//  MyReviewManageView.swift
//  Siksha
//
//  Created by 이수민 on 9/14/25.
//

import Combine
import SwiftUI
import SwiftyJSON

struct MyReviewManageView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel: MyReviewViewModel
    @State private var showReviewDeleteAlert = false
    @State private var showToast = false
    @State private var selectedReview: RestaurantReview?
    @State private var isDeleting = false

    init(viewModel: MyReviewViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        ZStack {
            Group {
                if viewModel.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if viewModel.restaurantSections.isEmpty {
                    VStack(alignment: .center) {
                        Spacer()
                        Text("내가 쓴 리뷰가 없어요")
                            .customFont(font: .text15(weight: .Bold))
                            .foregroundStyle(Color.gray600)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 0) {
                        ScrollView {
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.restaurantSections) { section in
                                    RestaurantSectionView(
                                        section: section,
                                        isExpanded: Binding(
                                            get: { viewModel.expandedSections[section.id] ?? false },
                                            set: { viewModel.toggleSection(section.id, expanded: $0) }
                                        ),
                                        showDeleteAlert: $showReviewDeleteAlert,
                                        selectedReview: $selectedReview
                                    )
                                    .background(Color.backgroundSecondary)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray200, lineWidth: 1)
                                    )
                                }
                            }
                            .padding(.top, 20)
                            .padding(.horizontal, 8)
                        }
                    }
                }
            }

            if showReviewDeleteAlert {
                Color.backgroundDim
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        if !isDeleting {
                            showReviewDeleteAlert = false
                        }
                    }

                reviewDeleteAlert
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 30)
            }

            ToastView(
                type: .check,
                message: "평가가 삭제되었습니다.",
                bottomMargin: 60,
                isVisible: showToast
            )
        }
        .background(Color.backgroundMain)
        .customNavigationBar(title: "나의 평가 관리")
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.loadReviews()
        }
    }

    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(.white)
        }
    }

    var reviewDeleteAlert: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 18.34)
            Text("평가 삭제")
                .customFont(font: .text16(weight: .ExtraBold))
                .foregroundStyle(Color.blackColor)
            Spacer()
                .frame(height: 7.23)
            Text("해당 평가를 정말 삭제하시겠습니까?")
                .customFont(font: .text13(weight: .Regular))
            Spacer()
                .frame(height: 13.84)
            Divider()
                .foregroundStyle(Color.borderPrimary)
            HStack(spacing: 0) {
                Button(action: {
                    if !isDeleting {
                        showReviewDeleteAlert = false
                    }
                }) {
                    Text("취소")
                        .customFont(font: .text16(weight: .ExtraBold))
                        .frame(maxWidth: .infinity)
                }
                .foregroundColor(.orange500)
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(isDeleting)

                Divider()
                    .foregroundStyle(Color.borderPrimary)

                Button(action: {
                    guard let reviewToDelete = selectedReview, !isDeleting else { return }

                    isDeleting = true

                    viewModel.deleteReview(reviewToDelete.id) { success in
                        isDeleting = false
                        showReviewDeleteAlert = false

                        if success {
                            viewModel.removeReviewFromSection(reviewId: reviewToDelete.id)

                            showToast = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                showToast = false
                            }
                        }
                    }
                }) {
                    if isDeleting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("삭제")
                            .customFont(font: .text16(weight: .Regular))
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color.gray700)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .disabled(isDeleting)
            }
        }
        .background(Color.backgroundSecondary)
        .frame(width: 315, height: 130.3)
        .cornerRadius(26)
    }
}

struct RestaurantSectionView: View {
    let section: RestaurantSection
    @Binding var isExpanded: Bool
    @Binding var showDeleteAlert: Bool
    @Binding var selectedReview: RestaurantReview?

    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                withAnimation {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text(section.name)
                        .customFont(font: .text16(weight: .Bold))
                        .foregroundColor(Color.blackColor)
                    Spacer()

                    Image("SelectGray")
                        .rotationEffect(.degrees(isExpanded ? 0 : 180))
                }
                .padding(.init(top: 13, leading: 16, bottom: 13, trailing: 16))
            }

            if isExpanded {
                Rectangle()
                    .fill(Color.orange500)
                    .frame(height: 1.5)
                    .padding(.horizontal, 15.5)
                    .padding(.bottom, 12)

                VStack(spacing: 16) {
                    ForEach(section.reviews) { review in
                        ReviewCardView(
                            review: review,
                            showDeleteAlert: $showDeleteAlert,
                            selectedReview: $selectedReview
                        )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
        }
        .background(Color.backgroundSecondary)
    }
}

struct ReviewCardView: View {
    let review: RestaurantReview
    @Binding var showDeleteAlert: Bool
    @Binding var selectedReview: RestaurantReview?
    @Environment(\.menuViewModel) var menuViewModel: MenuViewModel?
    @State private var cancellables = Set<AnyCancellable>()

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            NavigationLink(
                destination: {
                    let meal = review.menuDisplayModel
                    let mealInfoVM = MealInfoViewModel(
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
                    mealInfoVM.updateMealFromId()

                    return MealInfoView(viewModel: mealInfoVM)
                        .environment(\.menuViewModel, menuViewModel)
                        .onAppear {
                            menuViewModel?.reloadOnAppear = false
                        }
                },
                label: {
                    HStack(alignment: .center) {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(spacing: 4) {
                                Text(review.menuName)
                                    .customFont(font: .text15(weight: .ExtraBold))
                                    .foregroundStyle(Color.blackColor)
                                    .lineLimit(1)
                                    .truncationMode(.tail)

                                Image("ArrowGray800")
                                    .frame(width: 20, height: 20)

                                Spacer()

                                Text(review.date)
                                    .customFont(font: .text12(weight: .Bold))
                                    .foregroundColor(Color.gray600)
                            }

                            RatingStar(.constant(Double(review.rating)), size: 13, spacing: 2, emptyStarType: .filled)
                        }
                        .padding(.init(top: 12, leading: 12, bottom: 16, trailing: 0))
                        Spacer()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.elementTooltip2)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray200, lineWidth: 1)
                    )
                })

            if !review.reviewText.isEmpty {
                Text(review.reviewText)
                    .customFont(font: .text12(weight: .Regular))
                    .lineLimit(nil)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding(.top, 8)
                    .padding(.leading, 4)
            }

            if !review.tags.isEmpty {
                HStack(spacing: 10) {
                    ForEach(review.tags, id: \.self) { tag in
                        Text(tag)
                            .customFont(font: .text11(weight: .Bold))
                            .foregroundColor(Color.gray700)
                            .padding(4)
                            .background(Color.elementChip)
                            .cornerRadius(4)
                    }
                    Spacer()
                }
                .padding(.leading, 4)
            }

            if !review.imageUrls.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(review.imageUrls.indices, id: \.self) { index in
                            AsyncImage(url: URL(string: review.imageUrls[index])) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                RoundedRectangle(cornerRadius: 0)
                                    .fill(Color.gray200)
                            }
                            .frame(width: 48, height: 48)
                            .clipped()
                        }
                    }
                    .padding(.horizontal, 1)
                }
                .padding(.top, 4)
                .padding(.leading, 4)
            }

            HStack(spacing: 16) {
                Spacer()

                Button(
                    "삭제하기",
                    action: {
                        selectedReview = review
                        showDeleteAlert = true
                    }
                )
                .customFont(font: .text11(weight: .Bold))
                .foregroundColor(.gray600)

                NavigationLink(destination: {
                    let meal = review.menuDisplayModel
                    let mealInfoVM = MealInfoViewModel(
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
                    mealInfoVM.updateMealFromId()

                    return MealReviewView(meal, mealInfoViewModel: mealInfoVM, editingReview: review)
                        .environment(\.menuViewModel, menuViewModel)
                }) {
                    Text("수정하기")
                        .customFont(font: .text11(weight: .Bold))
                        .foregroundColor(.orange500)
                }
            }
            .padding(.top, 8)
        }
    }
}

private extension RestaurantReview {
    var menuDisplayModel: MenuItemDisplayModel {
        MenuItemDisplayModel(
            id: menuId,
            code: "",
            nameKr: menuName,
            nameEn: "",
            price: 0,
            score: Double(rating),
            reviewCount: 0,
            isLiked: false,
            likeCount: 0,
            imageURLStrings: []
        )
    }
}

#Preview {
    MyReviewManageView(
        viewModel: MyReviewViewModel(
            fetchMyReviewsUseCase: AppContainer.shared.useCases.fetchMyReviewsUseCase,
            deleteMyReviewUseCase: AppContainer.shared.useCases.deleteMyReviewUseCase
        ))
}
