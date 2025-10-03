//
//  MyReviewManageView.swift
//  Siksha
//
//  Created by 이수민 on 9/14/25.
//

import SwiftUI

struct MyReviewManageView<ViewModel>: View where ViewModel: MyReviewViewModel {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @StateObject var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    if viewModel.isLoading {
                        // TODO: LoadingIndicator
                        ProgressView()
                            .padding()
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.restaurantSections) { section in
                                RestaurantSectionView(
                                    section: section,
                                    isExpanded: Binding(
                                        get: { viewModel.expandedSections[section.id] ?? false },
                                        set: { viewModel.toggleSection(section.id, expanded: $0) }
                                    )
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
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 0))
                .foregroundColor(.white)
        }
    }
}

struct RestaurantSectionView: View {
    let section: RestaurantSection
    @Binding var isExpanded: Bool
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                Divider()
                    .frame(height: 1.5)
                    .background(Color.orange500)
                    .padding(.horizontal, 15.5)
                    .padding(.bottom, 12)
                VStack(spacing: 16) {
                    ForEach(section.reviews) { review in
                        ReviewCardView(review: review)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            },
            label: {
                HStack {
                    Text(section.name)
                        .customFont(font: .text16(weight: .Bold))
                        .foregroundColor(Color.blackColor)
                    Spacer()

                    Image("select")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(.init(top: 12, leading: 16, bottom: 5, trailing: 0))
                .background(Color.backgroundSecondary)
            }
        )
        .accentColor(.clear)
        .background(Color.backgroundSecondary)
    }
}

struct ReviewCardView: View {
    let review: RestaurantReview
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text(review.menuName)
                            .customFont(font: .text15(weight: .ExtraBold))
                            .foregroundStyle(Color.blackColor)
                        
                        Image("Arrow")
                            .frame(width: 20, height: 20)
                        
                        Spacer()
                        
                        Text(review.date)
                            .customFont(font: .text12(weight: .Bold))
                            .foregroundColor(Color.gray600)
                    }
                    
                    RatingStar(.constant(Double(review.rating)), size: 10, spacing: 2)
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
            
            // Bottom buttons
            HStack(spacing: 16) {
                Spacer()
                
                Button("삭제하기") {
                    // Delete action
                }
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
    MyReviewManageView(viewModel: MyReviewViewModel())
}
