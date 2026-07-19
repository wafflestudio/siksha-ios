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
    @State private var isAtLeadingEdge: Bool = true
    @State private var displayedFestivalSwitchOn: Bool
    @State private var festivalSwitchCommitTask: Task<Void, Never>?

    private let backgroundColor = Color.backgroundMain
    private let lightGrayColor = Color.gray600
    private let orangeColor = Color.orange500
    private let fontColor = Color.gray700
    private let festivalSwitchCommitDelayNanoseconds: UInt64 = 300_000_000
    private let typeInfos: [TypeInfo] = [
        TypeInfo(type: .breakfast),
        TypeInfo(type: .lunch),
        TypeInfo(type: .dinner),
    ]

    init(viewModel: MenuViewModel, selectedFilterType: Binding<MenuFilterType?>) {
        self.viewModel = viewModel
        self._selectedFilterType = selectedFilterType
        self._displayedFestivalSwitchOn = State(initialValue: viewModel.isFestivalSwitchOn)
    }

    var body: some View {
        VStack(alignment: .center, spacing: 0) {
            mealSelectorView
                .padding(.top, 15)

            filterSelectorView

            if viewModel.getMenuStatus == .loading {
                loadingView
            } else if viewModel.mealSections.count > 0 {
                TabView(selection: $viewModel.selectedPage) {
                    ForEach(viewModel.mealSections) { section in
                        RestaurantsView(
                            section.restaurantMenus,
                            section.type.rawValue,
                            viewModel.currentOperatingHourType,
                            onFavoriteTap: { restaurantId in
                                Task {
                                    await viewModel.toggleRestaurantLike(restaurantId)
                                }
                            }
                        )
                        .environment(\.menuViewModel, viewModel)
                        .tag(section.type.rawValue)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            } else {
                emptyView
            }
        }
        .background(backgroundColor)
        .alert(
            "위치정보 이용에 대한 엑세스 권한이 없어요.",
            isPresented: $viewModel.showDistanceAlert,
            actions: {
                Button("취소", action: {}).keyboardShortcut(.defaultAction)
                Button("설정하기") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
            },
            message: {
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
            HStack(alignment: .bottom, spacing: 24) {
                ForEach(typeInfos) { type in
                    typeButton(type: type)
                }
            }
            .frame(alignment: .center)

            if viewModel.showFestivalSwitch {
                HStack {
                    Spacer()
                    Toggle(isOn: festivalSwitchBinding) {
                    }
                    .toggleStyle(FestivalSwitchStyle())
                    .padding(EdgeInsets(top: 5.56, leading: 0, bottom: 0, trailing: 17))
                    .onAppear {
                        displayedFestivalSwitchOn = viewModel.isFestivalSwitchOn
                    }
                    .onChange(of: viewModel.isFestivalSwitchOn) { isOn in
                        displayedFestivalSwitchOn = isOn
                    }
                }
            }
        }.frame(maxWidth: .infinity)
    }

    var festivalSwitchBinding: Binding<Bool> {
        Binding(
            get: { displayedFestivalSwitchOn },
            set: { updateFestivalSwitch($0) }
        )
    }

    func updateFestivalSwitch(_ isOn: Bool) {
        festivalSwitchCommitTask?.cancel()
        displayedFestivalSwitchOn = isOn

        festivalSwitchCommitTask = Task { @MainActor in
            try? await Task.sleep(nanoseconds: festivalSwitchCommitDelayNanoseconds)
            guard !Task.isCancelled else {
                return
            }

            viewModel.setFestivalSwitchOn(isOn)
        }
    }

    var filterSelectorView: some View {
        HStack(spacing: 5) {
            Image(.Icons.Common.filterSliders)
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
                            isOn: viewModel.selectedFilters.isOpen ?? false,
                            isCheck: true
                        )
                        .onTapGesture {
                            viewModel.updateFilters { filters in
                                filters.isOpen = filters.isOpen == true ? nil : true
                            }
                            let isEnabled = viewModel.selectedFilters.isOpen == true
                            viewModel.analytics.track(
                                .instantFilterToggled(
                                    filter: .isOpenNow, value: isEnabled, pageName: viewModel.pageName)
                            )
                        }

                        FilterItem(
                            text: "즐겨찾기",
                            isOn: viewModel.selectedFilters.isFavorite ?? false,
                            isCheck: true
                        )
                        .onTapGesture {
                            viewModel.updateFilters { filters in
                                filters.isFavorite = filters.isFavorite == true ? nil : true
                            }
                            let isEnabled = viewModel.selectedFilters.isFavorite == true
                            viewModel.analytics.track(
                                .instantFilterToggled(
                                    filter: .isFavorite, value: isEnabled, pageName: viewModel.pageName)
                            )
                        }

                        FilterItem(
                            text: "리뷰",
                            isOn: viewModel.selectedFilters.hasReview ?? false,
                            isCheck: true
                        )
                        .onTapGesture {
                            viewModel.updateFilters { filters in
                                filters.hasReview = filters.hasReview == true ? nil : true
                            }
                            let isEnabled = viewModel.selectedFilters.hasReview == true
                            viewModel.analytics.track(
                                .instantFilterToggled(
                                    filter: .hasReviews, value: isEnabled, pageName: viewModel.pageName))
                        }

                        FilterItem(
                            text: viewModel.minRatingLabel,
                            isOn: viewModel.selectedFilters.minimumRating != nil,
                            isCheck: false
                        )
                        .onTapGesture {
                            selectedFilterType = .minimumRating
                        }
                    }
                    .background(
                        GeometryReader {
                            Color.clear.preference(
                                key: HorizontalOffsetKey.self,
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
                            LinearGradient(
                                colors: [.backgroundPrimary, .backgroundPrimary.opacity(0)], startPoint: .leading,
                                endPoint: .trailing)
                        )
                        .frame(width: 16, height: 34)
                }
            }
        }
        .padding(EdgeInsets(top: 17, leading: 9, bottom: 9, trailing: 9))
        .onChange(of: selectedFilterType) { newType in
            if let newType {
                viewModel.analytics.track(
                    .filterModalOpened(entryPoint: newType.entryPointString, pageName: viewModel.pageName))
            }
        }
    }

    var emptyView: some View {
        VStack {
            Spacer()
            Text("식단 정보가 없습니다")
                .customFont(font: .text15(weight: .Bold))
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
            VStack(spacing: 3) {
                Image(type.icon)
                    .renderingMode(.template)
                    .resizable()
                    .frame(width: 20, height: 20)
                    .foregroundColor(viewModel.selectedPage == type.id ? orangeColor : lightGrayColor)
                Text(type.name)
                    .font(.custom(viewModel.selectedPage == type.id ? "NanumSquareOTFB" : "NanumSquareOTFR", size: 11))
                    .foregroundColor(viewModel.selectedPage == type.id ? orangeColor : lightGrayColor)
            }
        }
    }

}

struct HorizontalOffsetKey: PreferenceKey {
    static let defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value += nextValue()
    }
}

struct MenuListView_Previews: PreviewProvider {
    struct ContainerView: View {
        @State var selectedFilterType: MenuFilterType? = .all
        var body: some View {
            MenuListView(
                viewModel: MenuViewModel(
                    fetchDailyMenuUseCase: AppContainer.shared.useCases.fetchDailyMenuUseCase,
                    fetchFestivalDatesUseCase: AppContainer.shared.useCases.fetchFestivalDatesUseCase,
                    fetchRemoteConfigUseCase: AppContainer.shared.useCases.fetchRemoteConfigUseCase,
                    observeRemoteConfigUseCase: AppContainer.shared.useCases.observeRemoteConfigUseCase,
                    fetchPersonalRestaurantsUseCase: AppContainer.shared.useCases.fetchPersonalRestaurantsUseCase,
                    updateRestaurantPreferenceUseCase: AppContainer.shared.useCases.updateRestaurantPreferenceUseCase,
                    manageMenuFiltersUseCase: AppContainer.shared.useCases.manageMenuFiltersUseCase,
                    manageRestaurantsWithoutMenuVisibilityUseCase: AppContainer.shared.useCases
                        .manageRestaurantsWithoutMenuVisibilityUseCase,
                    manageFestivalPreferencesUseCase: AppContainer.shared.useCases.manageFestivalPreferencesUseCase,
                    checkFestivalSwitchVisibilityUseCase: AppContainer.shared.useCases
                        .checkFestivalSwitchVisibilityUseCase
                ),
                selectedFilterType: $selectedFilterType
            )
        }
    }

    static var previews: some View {
        ContainerView()
    }
}
