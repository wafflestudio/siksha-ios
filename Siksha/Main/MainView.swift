//
//  MainView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI

private extension MainView {
    
    // Pager Tab Button
    func dayButton(day: DayInfo, _ geometry: GeometryProxy) -> some View {
        Button(action: {
            withAnimation(.easeInOut) {
                viewModel.selectedPage = day.id
            }
        }) {
            ZStack(alignment: .bottom) {
                    Text(day.date)
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

struct MainView: View {
    struct DayInfo: Identifiable {
        var id: Int
        var dayType: DaySelection
        var date: String
        var dailyMenuView = DailyMenuView()
        
        init(type: DaySelection, date: String) {
            self.id = type.rawValue
            self.date = date
            self.dayType = type
        }
    }
    
    let dayInfos: [DayInfo] = [
        DayInfo(type: .today, date: "02. 01. 월"),
        DayInfo(type: .tomorrow, date: "02. 02. 화")
    ]
    
    let lightGrayColor = Color.init("LightGrayColor")
    let orangeColor = Color.init("MainThemeColor")
    
    @ObservedObject var viewModel = MainViewModel()
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                // Navigation Bar
                ZStack {
                    Image("NaviBar")
                        .resizable()
                        .frame(width: geometry.size.width, height: geometry.safeAreaInsets.top+40)
                        .padding(.top, -geometry.safeAreaInsets.top)
                    
                    Image("Logo")
                }
                // Navigaiton Bar
                
                // Day Page Tab
                HStack(spacing: 0) {
                    ForEach(dayInfos) { day in
                        dayButton(day: day, geometry)
                    }
                }
                .background(Color.white.shadow(color: .init(white: 0.9), radius: 2, x: 0, y: 3.5))
                
                PageView(currentPage: $viewModel.selectedPage, dayInfos.map{ $0.dailyMenuView })
            }
            
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
