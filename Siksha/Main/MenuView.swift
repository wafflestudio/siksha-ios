//
//  MenuView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI

private extension MenuView {
    // Pager Tab Button
    func dayButton(day: DayInfo, _ geometry: GeometryProxy) -> some View {
        Button(action: {
            viewModel.scroll = day.id - viewModel.selectedPage
            viewModel.selectedPage = day.id
        }) {
            ZStack(alignment: .bottom) {
                Text(appState.dateFormatted[day.id])
                        .font(.custom("NanumSquareOTFB", size: 15))
                        .foregroundColor(viewModel.selectedPage == day.id ? orangeColor : lightGrayColor)
                .padding([.top, .bottom], 12)
                
                orangeColor
                    .frame(height: 2)
                    .opacity(viewModel.selectedPage == day.id ? 1 : 0)
            }
        }
        .frame(width: geometry.size.width/2)
        .transition(.opacity)
    }
}

// MARK: - Menu View

struct MenuView: View {
    struct DayInfo: Identifiable {
        var id: Int
        var dayType: DaySelection
        var dailyMenuView: DailyMenuView
        
        init(type: DaySelection) {
            self.id = type.rawValue
            self.dayType = type
            self.dailyMenuView = DailyMenuView(type)
        }
    }
    
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel = MenuViewModel()
    
    let lightGrayColor = Color.init("LightGrayColor")
    let orangeColor = Color.init("MainThemeColor")
    
    let dayInfos: [DayInfo] = [
        DayInfo(type: .today),
        DayInfo(type: .tomorrow)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Navigation Bar
                ZStack {
                    Image("NaviBar")
                        .resizable()
                        .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top+55)
                        .padding(.top, -geometry.safeAreaInsets.top)
                    
                    Image("Logo")
                        .padding(.bottom, 5)
                }
                // Navigaiton Bar
                
                // Day Page Tab
                HStack(spacing: 0) {
                    ForEach(dayInfos) { day in
                        dayButton(day: day, geometry)
                    }
                }
                .background(Color.white.shadow(color: .init(white: 0.9), radius: 2, x: 0, y: 3.5))
                
                PageView(currentPage: $viewModel.selectedPage, scroll: $viewModel.scroll, dayInfos.map{ $0.dailyMenuView })
                    .background(Color.init("AppBackgroundColor"))
                    .padding(.top, -3)
            }
        }
        .onAppear {
            if viewModel.appState == nil {
                viewModel.appState = appState
            }
            viewModel.scroll = 0
        }
    }
}

// MARK: - Preview

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
            .environmentObject(AppState())
    }
}
