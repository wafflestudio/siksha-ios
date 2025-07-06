//
//  MenuListView.swift
//  Siksha
//
//  Created by 이지현 on 3/16/25.
//

import SwiftUI
import Mixpanel

struct MenuListView: View {
    @ObservedObject var viewModel: MenuViewModel
    @Binding var selectedFilterType: MenuFilterType?
    @State private var isAtLeadingEdge: Bool = true
    
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
            mealSelectorView
                .padding(.top, 15)
            
            filterSelectorView
            
            if viewModel.getMenuStatus == .loading {
                loadingView
            } else if viewModel.restaurantsLists.count > 0 {
                TabView(selection: $viewModel.selectedPage) {
                    ForEach(viewModel.restaurantsLists.indices, id: \.self) { index in
                        RestaurantsView(viewModel.restaurantsLists[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            } else {
                emptyView
            }
        }
        .background(backgroundColor)
        .alert("위치정보 이용에 대한 엑세스 권한이 없어요.", isPresented: $viewModel.showDistanceAlert, actions: {
            Button("취소", action: {}).keyboardShortcut(.defaultAction)
            Button("설정하기") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
        }, message: {
            Text("앱 설정으로 가서 위치 권한을 수정할 수 있어요. 이동하시겠어요?")
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
            
            if viewModel.showFestivalSwitch {
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
        HStack(spacing: 5) {
            Image("Filter")
                .resizable()
                .frame(width: 34, height: 34)
                .onTapGesture {
                    selectedFilterType = .all
                }
            ZStack(alignment: .leading) {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 5) {
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
                            Mixpanel.mainInstance().track(
                                event: "instant_filter_toggled",
                                properties: [
                                    "filter_type": "is_open_now",
                                    "filter_value": viewModel.selectedFilters.isOpen ?? true,
                                    "page_name": viewModel.mixpanelPageName
                                ]
                            )
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
                            Mixpanel.mainInstance().track(
                                event: "instant_filter_toggled",
                                properties: [
                                    "filter_type": "has_reviews",
                                    "filter_value": viewModel.selectedFilters.hasReview ?? true,
                                    "page_name": viewModel.mixpanelPageName
                                ]
                            )
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
                    .background(
                        GeometryReader {
                            Color.clear.preference(key: HorizontalOffsetKey.self,
                                                value: $0.frame(in: .named("filterScroll")).origin.x)
                        }
                    )
                    .onPreferenceChange(HorizontalOffsetKey.self) { offset in
                        withAnimation {
                            isAtLeadingEdge = offset >= 0
                        }
                    }
                }
                .coordinateSpace(name: "filterScroll")
                
                if !isAtLeadingEdge {
                    Rectangle()
                        .foregroundStyle(.clear)
                        .background(
                            LinearGradient(colors: [Color("Gray50"), Color("Gray50").opacity(0)], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(width: 16, height: 34)
                }
            }
        }
        .padding(EdgeInsets(top: 17, leading: 9, bottom: 9, trailing: 9))
        .onChange(of: selectedFilterType) { newType in
            if let newType {
                Mixpanel.mainInstance()
                    .track(
                        event: "filter_modal_opened",
                        properties: [
                            "entry_point": newType.mixpanelEntryPoint,
                            "page_name": viewModel.mixpanelPageName
                        ]
                    )
            }
        }

    }
    
    var emptyView: some View {
        VStack {
            Spacer()
            Text("식단 정보가 없습니다")
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

struct HorizontalOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct MenuListView_Previews: PreviewProvider {
    struct ContainerView: View {
        @State var selectedFilterType: MenuFilterType? = .all
        var body: some View {
            MenuListView(viewModel: MenuViewModel(isFavoriteTab: false), selectedFilterType: $selectedFilterType)
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}
