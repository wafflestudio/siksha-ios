//
//  MenuListView.swift
//  Siksha
//
//  Created by 이지현 on 3/16/25.
//

import SwiftUI

struct MenuListView: View {
    @ObservedObject var viewModel: MenuViewModel
    @Binding var selectedFilterType: MenuFilterType?
    
    private let backgroundColor = Color("AppBackgroundColor")
    private let lightGrayColor = Color("Gray600")
    private let orangeColor = Color("main")
    private let fontColor = Color("DefaultFontColor")
    private let typeInfos: [TypeInfo] = [
        TypeInfo(type: .breakfast),
        TypeInfo(type: .lunch),
        TypeInfo(type: .dinner)
    ]
    
    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            if viewModel.getMenuStatus == .loading {
                loadingView
            } else {
                mealSelectorView
                    .padding(.top, 15)
                
                filterSelectorView
                
                if viewModel.restaurantsLists.count > 0 {
                    PageView(
                        currentPage: $viewModel.selectedPage,
                        needReload: $viewModel.pageViewReload,
                        viewModel.restaurantsLists.map { RestaurantsView($0).environment(\.menuViewModel, viewModel) })
                } else {
                    emptyView
                }
            }
        }
        .background(backgroundColor)
        .alert("Error", isPresented: $viewModel.showDistanceAlert, actions: {
            Button("취소") {}
            Button("위치 설정으로 이동") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }, message: {
            Text("위치 정보를 가져올 수 없습니다. 거리 필터를 해제합니다.")
        })
    }
}

// MARK: - Subviews

private extension MenuListView {
    var loadingView: some View {
        VStack {
            Spacer()
            ActivityIndicator(isAnimating: .constant(true), style: .large)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    var mealSelectorView: some View {
        ZStack {
            HStack(alignment: .bottom, spacing: 28) {
                ForEach(typeInfos) { type in
                    typeButton(type: type)
                }
            }
            .frame(alignment: .center)
            
            if viewModel.isFestivalAvailable {
                HStack {
                    Spacer()
                    Toggle(isOn: $viewModel.isFestival) {
                    }
                    .toggleStyle(FestivalSwitchStyle())
                    .padding(EdgeInsets(top: 5.56, leading: 0, bottom: 0, trailing: 17))
                }
            }
        }.frame(maxWidth: .infinity)
    }
    
    var filterSelectorView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                Image("Filter")
                    .resizable()
                    .frame(width: 34, height: 34)
                    .onTapGesture {
                        selectedFilterType = .all
                    }
                
                FilterItem(
                    text: viewModel.distanceLabel,
                    isOn: viewModel.selectedFilters.distance != nil,
                    isCheck: false
                ).onTapGesture {
                    selectedFilterType = .distance
                }
                
                FilterItem(
                    text: viewModel.priceLabel,
                    isOn: viewModel.selectedFilters.priceRange != nil,
                    isCheck: false
                )
                .onTapGesture {
                    selectedFilterType = .price
                }
                
                FilterItem(
                    text: "영업 중",
                    isOn:viewModel.selectedFilters.isOpen ?? false,
                    isCheck: true
                )
                .onTapGesture {
                    if let _ = viewModel.selectedFilters.isOpen {
                        viewModel.selectedFilters.isOpen?.toggle()
                    } else {
                        viewModel.selectedFilters.isOpen = true
                    }
                    viewModel.saveFilters()
                }
                
                FilterItem(
                    text: "리뷰",
                    isOn:viewModel.selectedFilters.hasReview ?? false,
                    isCheck: true
                )
                .onTapGesture {
                    if let _ = viewModel.selectedFilters.hasReview {
                        viewModel.selectedFilters.hasReview?.toggle()
                    } else {
                        viewModel.selectedFilters.hasReview = true
                    }
                    viewModel.saveFilters()
                }
                
                FilterItem(
                    text:viewModel.minRatingLabel,
                    isOn:viewModel.selectedFilters.minimumRating != nil,
                    isCheck: false
                )
                .onTapGesture {
                    selectedFilterType = .minimumRating
                }
                
//                FilterItem(
//                    text: viewModel.categoryLabel,
//                    isOn:viewModel.selectedFilters.categories != nil,
//                    isCheck: false
//                )
//                .onTapGesture {
//                    selectedFilterType = .category
//                }
            }
            .padding(EdgeInsets(top: 17, leading: 9, bottom: 15, trailing: 9))
        }

    }
    
    var emptyView: some View {
        VStack {
            Spacer()
            Text("불러온 식단이 없습니다")
                .font(.custom("NanumSquareOTFB", size: 15))
                .foregroundColor(fontColor)
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
    }
    
    func typeButton(type: TypeInfo) -> some View {
        Button(action: {
            viewModel.selectedPage = type.id
        }) {
            VStack {
                Image(type.icon)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: type.width, height: type.height)
                    .foregroundColor(viewModel.selectedPage == type.id ? orangeColor : lightGrayColor)
                    .padding(.leading, type.id == 2 ? 3 : 0)
                    .padding(.bottom, type.id == 1 ? 0 : 2)
                Text(type.name)
                    .font(.custom(viewModel.selectedPage == type.id ? "NanumSquareOTFB" : "NanumSquareOTFR", size: 10))
                    .foregroundColor(viewModel.selectedPage == type.id ? orangeColor : lightGrayColor)
            }
        }
    }

}
