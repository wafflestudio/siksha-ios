//
//  MyReviewManageView.swift
//  Siksha
//
//  Created by 이수민 on 9/14/25.
//

import SwiftUI

struct MyReviewManageView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel: MyReviewViewModel
    @State private var showReviewDeleteAlert = false
    @State private var showToast = false
    @State private var selectedReview: RestaurantReview?
    
    init(viewModel: MyReviewViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
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
                            .font(.custom("NanumSquareOTF", size: 15))
                            .foregroundColor(Color(white: 166/255))
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
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        showReviewDeleteAlert = false
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
                Button(action: { showReviewDeleteAlert = false }) {
                    Text("취소")
                        .customFont(font: .text16(weight: .ExtraBold))
                        .frame(maxWidth: .infinity)
                }
                .foregroundColor(.orange500)
                .frame(maxWidth: .infinity, alignment: .center)
                
                Divider()
                    .foregroundStyle(Color.borderPrimary)
                
                Button(action: {
                    showReviewDeleteAlert = false
                    showToast = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        showToast = false
                    }
                }) {
                    Text("삭제")
                        .customFont(font: .text16(weight: .Regular))
                        .frame(maxWidth: .infinity)
                        .foregroundStyle(Color.gray700)
                }
                .frame(maxWidth: .infinity, alignment: .center)
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
            
            // 내용
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(review.menuName)
                            .customFont(font: .text15(weight: .ExtraBold))
                            .foregroundStyle(Color.blackColor)
                        
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
            
            Text(review.reviewText)
                .customFont(font: .text12(weight: .Regular))
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.top, 8)
                .padding(.leading, 4)
            
            // Tags
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
            
            // Food images
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
            
            // Bottom buttons
            HStack(spacing: 16) {
                Spacer()
                
                Button("삭제하기", action: {
                    selectedReview = review
                    showDeleteAlert = true
                })
                .customFont(font: .text11(weight: .Bold))
                .foregroundColor(.gray600)
                
                Button("수정하기") {
                    // Edit action
                }
                .customFont(font: .text11(weight: .Bold))
                .foregroundColor(.orange500)
            }
            .padding(.top, 8)
        }
    }
}


#Preview {
    MyReviewManageView(viewModel: MyReviewViewModel(repository: DomainManager.shared.domain.userRepository))
}
