//
//  MenuView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI

struct MenuView: View {
    @Environment(\.safeAreaInsets) private var safeAreaInsets
    
    @StateObject private var viewModel: MenuViewModel
    @State private var selectedFilterType: MenuFilterType? = nil
    
    private let lightGrayColor = Color("LightGrayColor")
    
    init(isFavoriteTab: Bool = false) {
        _viewModel = StateObject(wrappedValue: MenuViewModel(isFavoriteTab: isFavoriteTab))
    }
    
    private var isFilterModalPresented: Binding<Bool> {
        Binding(
            get: { selectedFilterType != nil },
            set: { newValue in
                if !newValue { selectedFilterType = nil }
            }
        )
    }
    
    private var selectedModalHeight: CGFloat {
        selectedFilterType?.modalSheetHeight ?? 0
    }
    
    private let dimBackgroundColor = Color(.sRGB, white: 0, opacity: 0.6)
    private let orangeColor = Color("main")
    
    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isFestivalAvailable {
                festivalBanner
            }
            
            if viewModel.noFavorites {
                Spacer()
                Text("즐겨찾기에 추가된 식당이 없습니다.\n식당 탭에서 별을 눌러 추가해보세요.")
                    .font(.custom("NanumSquareOTFB", size: 14))
                    .foregroundColor(lightGrayColor)
                Spacer()
            } else {
                daySelectorView
                
                ZStack(alignment: .top) {
                    MenuListView(
                        viewModel: viewModel,
                        selectedFilterType: $selectedFilterType
                    )
                    
                    if viewModel.showCalendar {
                        calendarOverlay
                    }
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
            } else {
                viewModel.reloadOnAppear = true
            }
            viewModel.loadFilters()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            viewModel.getMenu(date: viewModel.selectedDate)
        }
        .sheet(isPresented: isFilterModalPresented){
            // TODO: - 버전 16으로 올릴 경우 분기처리 필요 X
            if #available(iOS 16.0, *) {
                MenuFilterView(menuViewModel: viewModel, menuFilterType: selectedFilterType ?? .all)
                    .presentationDetents([.height(selectedModalHeight - safeAreaInsets.bottom)])
            } else {
                GeometryReader { geometry in
                    VStack {
                        MenuFilterView(menuViewModel: viewModel, menuFilterType: selectedFilterType ?? .all)
                        .frame(height: min(selectedModalHeight, geometry.size.height * 0.9))
                        Spacer()
                    }
                    .frame(width: geometry.size.width)
                }
                .edgesIgnoringSafeArea(.bottom)
            }
        }
    }
}

// MARK: - Subviews

private extension MenuView {
    
    var festivalBanner: some View {
        Button(action: {
            openInstagram()
        }) {
            Image("FestivalBanner")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
        }
    }
    
    var daySelectorView: some View {
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
    
    var calendarOverlay: some View {
        ZStack(alignment: .top) {
            dimBackgroundColor
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

// MARK: - Functions

private extension MenuView {
    
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
