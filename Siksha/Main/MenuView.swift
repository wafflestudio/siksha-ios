//
//  MenuView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI

private extension MenuView {
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
    
    var dayPageTab: some View {
        HStack(alignment: .center) {
            Button(action: {
                viewModel.selectedDate = viewModel.prevDate
            }, label: {
                Image(viewModel.showCalendar ? "PrevDate-disabled" : "PrevDate")
                    .resizable()
                    .frame(width: 10, height: 16)
            })
            .disabled(viewModel.showCalendar)
            .padding(.leading, 16)
            
            Spacer()
            
            Button(action: {
                viewModel.showCalendar.toggle()
            }, label: {
                HStack(alignment: .center, spacing: 0) {
                    Image("Calendar")
                        .renderingMode(.original)
                        .frame(width: 20, height: 22)
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 4))
                    Text(viewModel.selectedFormatted)
                        .font(.custom("NanumSquareOTFEB", size: 15))
                        .foregroundColor(orangeColor)
                }
            })
            
            Spacer()
            
            Button(action: {
                viewModel.selectedDate = viewModel.nextDate
            }, label: {
                Image(viewModel.showCalendar ? "NextDate-disabled" : "NextDate")
                    .resizable()
                    .frame(width: 10, height: 16)
            })
            .disabled(viewModel.showCalendar)
            .padding(.trailing, 16)
           
        }
        .frame(height: 50)
    }
    struct CustomSwitchStyle:ToggleStyle{
        func makeBody(configuration: Configuration) -> some View {
            RoundedRectangle(cornerSize: CGSize(width: 9.69, height: 9.69))
                .fill(configuration.isOn ? Color("MainThemeColor") : Color("ReviewLowColor"))
                .frame(width:45,height:19)
                .overlay(
                    Circle()
                        .fill(Color.white)
                        .frame(width:17,height: 17,alignment: .leading)
                        .offset(x: configuration.isOn ? 26.19 : 1.6,y:0)
                    ,alignment: .leading
                )
                .overlay(
                    Text("축제")
                        .foregroundColor(Color.white)
                        .font(.custom("NanumSquareOTFB", size: 9))
                        .offset(x: configuration.isOn ? 6.5 : 21.83,y:0)
                    ,alignment: .leading
                            
                )
                .onTapGesture {
                    withAnimation{
                        configuration.$isOn.wrappedValue.toggle()
                    }
                }
        }
        
    }
    var menuList: some View {
        // Menus
        VStack(alignment: .center) {
            if viewModel.getMenuStatus == .loading {
                VStack {
                    Spacer()
                    ActivityIndicator(isAnimating: .constant(true), style: .large)
                    Spacer()
                }
                .frame(maxWidth: .infinity)
            } else {
                if viewModel.restaurantsLists.count > 0 {
                    if viewModel.isFestivalAvailable{
                        ZStack{
                            HStack(alignment: .bottom, spacing: 28) {
                                ForEach(typeInfos) { type in
                                    typeButton(type: type)
                                }
                            }.padding(.top, 8)
                                .frame(alignment: .center)
                            VStack(alignment:   .trailing){
                                Toggle(isOn: $viewModel.isFestival) {
                                }
                                .toggleStyle(CustomSwitchStyle())
                                .padding(EdgeInsets(top: 5.56, leading: 0, bottom: 0, trailing: 17))
                                
                            }.frame(maxWidth: .infinity,alignment:.trailing)
                            
                        }.frame(maxWidth: .infinity)
                    }
                    else{
                        HStack(alignment: .bottom, spacing: 28) {
                            ForEach(typeInfos) { type in
                                typeButton(type: type)
                            }
                        }.padding(.top, 8)
                    }
                    ScrollView(.horizontal,showsIndicators: false){
                        HStack(spacing:5){
                            Image("Filter")
                                .onTapGesture {
                                    selectedFilterType = .all
                                    isFilterModal = true
                                }
                                
                            FilterItem(text: viewModel.distanceLabel,isOn: viewModel.selectedFilters.distance != nil, isCheck: false)
                                .onTapGesture {
                                    selectedFilterType = .distance
                                    isFilterModal = true
                                }
                            FilterItem(text: viewModel.priceLabel,isOn: viewModel.selectedFilters.priceRange != nil, isCheck: false)
                                .onTapGesture {
                                    selectedFilterType = .price
                                    isFilterModal = true
                                }
                            FilterItem(text: "영업 중",isOn:viewModel.selectedFilters.isOpen ?? false,isCheck: true)
                                .onTapGesture {
                                    
                                    if let hasReviewFilter = viewModel.selectedFilters.isOpen{
                                        viewModel.selectedFilters.isOpen?.toggle()
                                    }
                                    else{
                                        viewModel.selectedFilters.isOpen = true
                                    }
                                    viewModel.saveFilters()
                                }
                            FilterItem(text: "리뷰",isOn:viewModel.selectedFilters.hasReview ?? false,isCheck: true)
                                .onTapGesture {
                                    
                                    if let hasReviewFilter = viewModel.selectedFilters.hasReview{
                                        viewModel.selectedFilters.hasReview?.toggle()
                                    }
                                    else{
                                        viewModel.selectedFilters.hasReview = true
                                    }
                                    viewModel.saveFilters()
                                }
                            FilterItem(text:viewModel.minRatingLabel,isOn:viewModel.selectedFilters.minimumRating != nil,isCheck: false)
                                .onTapGesture {
                                    selectedFilterType = .minimumRating
                                    isFilterModal = true
                                }
                            FilterItem(text: viewModel.categoryLabel,isOn:viewModel.selectedFilters.categories != nil,isCheck: false)
                                .onTapGesture {
                                    selectedFilterType = .category
                                    isFilterModal = true
                                }
                            
                        }
                        
                        .padding(EdgeInsets(top: 17, leading: 0, bottom: 17, trailing: 0))
                    }
                    
                    if #available(iOS 15, *) {
                        TabView(selection: $viewModel.selectedPage) {
                            RestaurantsView(viewModel.restaurantsLists[0])
                                .environment(\.menuViewModel, viewModel)
                                .tag(0)
                            RestaurantsView(viewModel.restaurantsLists[1])
                                .environment(\.menuViewModel, viewModel)
                                .tag(1)
                            RestaurantsView(viewModel.restaurantsLists[2])
                                .environment(\.menuViewModel, viewModel)
                                .tag(2)
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    } else {
                        PageView(
                            currentPage: $viewModel.selectedPage,
                            needReload: $viewModel.pageViewReload,
                            viewModel.restaurantsLists.map { RestaurantsView($0).environment(\.menuViewModel, viewModel) })
                    }
                    
                } else {
                    VStack {
                        Spacer()
                        Text("불러온 식단이 없습니다")
                            .font(.custom("NanumSquareOTFB", size: 15))
                            .foregroundColor(fontColor)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.init("AppBackgroundColor"))
                }
            }
        }
        .background(Color.init("AppBackgroundColor"))
    }
}

// MARK: - Menu View

struct MenuView: View {
    @StateObject var viewModel = MenuViewModel()
    @State var isFilterModal = false
    @State var selectedFilterType: MenuFilterType = .all
    @State var selectedModalHeight: CGFloat = 727
    private let lightGrayColor = Color.init("LightGrayColor")
    private let orangeColor = Color.init("main")
    private let fontColor = Color("DefaultFontColor")
    
    var typeInfos: [TypeInfo] = [
        TypeInfo(type: .breakfast),
        TypeInfo(type: .lunch),
        TypeInfo(type: .dinner)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            if(viewModel.isFestivalAvailable){
                Button(action: {
                    openInstagram()
                }) {
                    Image("FestivalBanner")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                }
            }
            dayPageTab
            
            ZStack(alignment: .top) {
                menuList
                
                if viewModel.showCalendar {
                    Color.init(.sRGB, white: 0, opacity: 0.6)
                        .onTapGesture {
                            viewModel.showCalendar = false
                        }
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                        .zIndex(1)
                    
                    CalendarView(selectedDate: $viewModel.selectedDate)
                        .frame(height: 300)
                        .padding(EdgeInsets(top: 4, leading: 10, bottom: 15, trailing: 10))
                        .background(Color.white)
                        .transition(.opacity.animation(.easeInOut(duration: 0.3)))
                        .zIndex(2)
                }
            }
        }
        .customNavigationBar(title: "icon")
        .alert(isPresented: $viewModel.showNetworkAlert, content: {
            Alert(title: Text("식단"), message: Text("식단을 받아오지 못했습니다. 이전에 불러왔던 식단으로 대신 표시합니다."), dismissButton: .default(Text("확인")))
        })
        .onAppear {
            if viewModel.reloadOnAppear {
                viewModel.getMenu(date: viewModel.selectedDate)
                viewModel.loadFilters()
            } else {
                viewModel.reloadOnAppear = true
                viewModel.loadFilters()
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.getMenu(date: viewModel.selectedDate)
        }
        .onChange(of: selectedFilterType) { newValue in
            selectedModalHeight = newValue.modalSheetHeight
        }
        .sheet(isPresented:$isFilterModal){
            // TODO: - 버전 16으로 올릴 경우 분기처리 필요 X
            if #available(iOS 16.0, *) {
                MenuFilterView(menuViewModel: viewModel, menuFilterType: $selectedFilterType)
                    .presentationDetents([.height(selectedModalHeight)])
            } else {
                GeometryReader { geometry in
                    VStack {
                        MenuFilterView(menuViewModel: viewModel, menuFilterType: $selectedFilterType)
                        .frame(height: min(selectedModalHeight, geometry.size.height * 0.9))
                        Spacer()
                    }
                    .frame(width: geometry.size.width)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
    func openInstagram() {
        let appURL = URL(string: "instagram://user?username=snufestival")!
        let webURL = URL(string: "https://www.instagram.com/snufestival/")!
        if UIApplication.shared.canOpenURL(appURL) {
            UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.open(webURL, options: [:], completionHandler: nil)
        }
    }
}

// MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
    }
}
