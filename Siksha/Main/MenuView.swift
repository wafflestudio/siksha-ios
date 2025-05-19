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
    @State private var viewHeight: CGFloat = 0
    
    private let lightGrayColor = Color("Gray600")
    
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
        guard let selectedFilterType else {
            return 0
        }
        
        if selectedFilterType == .all {
            // viewHeight에 탭바 높이(50)와 추가 높이(3)를 더함
            return viewHeight + 50 + 3
        } else {
            // safeAreaInsets.bottom을 제외한 모달 시트 높이로 설정
            return selectedFilterType.modalSheetHeight - safeAreaInsets.bottom
        }
    }
    
    private let dimBackgroundColor = Color(.sRGB, white: 0, opacity: 0.6)
    private let orangeColor = Color("Orange500")
    
    var body: some View {
        VStack(spacing: 0) {
//            if viewModel.isFestivalAvailable {
//                festivalBanner
//            }
            
            if viewModel.noFavorites {
                Spacer()
                Text("즐겨찾기에 추가된 식당이 없습니다.")
                    .font(.custom("NanumSquareOTFB", size: 15))
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
        .measureHeight($viewHeight)
        .customNavigationBar(title: "icon")
        .alert(isPresented: $viewModel.showNetworkAlert, content: {
            Alert(title: Text("식단"), message: Text("식단을 받아오지 못했습니다. 이전에 불러왔던 식단으로 대신 표시합니다."), dismissButton: .default(Text("확인")))
        })
//        .onAppear {
//            if viewModel.reloadOnAppear {
//                viewModel.getMenu(date: viewModel.selectedDate)
//            } else {
//                viewModel.reloadOnAppear = true
//            }
//            viewModel.loadFilters()
//        }
//        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
//            viewModel.getMenu(date: viewModel.selectedDate)
//        }
        .sheet(isPresented: isFilterModalPresented){
            MenuFilterView(menuViewModel: viewModel, menuFilterType: selectedFilterType ?? .all)
                .presentationDetents([.height(selectedModalHeight)])
                .presentationCornerRadius(15)
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
