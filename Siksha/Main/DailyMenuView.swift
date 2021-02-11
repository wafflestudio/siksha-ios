//
//  DailyMenuView.swift
//  Siksha
//
//  Created by 박종석 on 2021/02/01.
//

import SwiftUI

private extension DailyMenuView {
    func typeButton(type: TypeInfo) -> some View {
        Button(action: {
            viewModel.scroll = type.id - viewModel.selectedPage
            viewModel.selectedPage = type.id
        }) {
            Image(type.icon)
                .renderingMode(.template)
                .resizable()
                .frame(width: type.width, height: type.height)
                .foregroundColor(viewModel.selectedPage == type.id ? orangeColor : lightGrayColor)
                .padding(.leading, type.id == 2 ? 6 : 0)
        }
    }
}

// MARK: - Daily Menu View

struct DailyMenuView: View {
    struct TypeInfo: Identifiable {
        var id: Int
        var type: TypeSelection
        var icon: String
        var height: CGFloat
        var width: CGFloat
        var restaurantsView: RestaurantsView
        
        init(day: DaySelection, type: TypeSelection) {
            self.id = type.rawValue
            self.type = type
            self.restaurantsView = RestaurantsView(day, type)
            
            switch(type){
            case .breakfast:
                self.icon = "Breakfast"
                self.width = 20
                self.height = 12
            case .lunch:
                self.icon = "Lunch"
                self.width = 20
                self.height = 20
            case .dinner:
                self.icon = "Dinner"
                self.width = 14
                self.height = 14
            }
        }
    }
    private let lightGrayColor = Color.init("LightGrayColor")
    private let orangeColor = Color.init("MainThemeColor")
    
    @ObservedObject var viewModel: DailyMenuViewModel
    
    var typeInfos: [TypeInfo]
    
    init(_ day: DaySelection){
        viewModel = DailyMenuViewModel()
        self.typeInfos = [
            TypeInfo(day: day, type: .breakfast),
            TypeInfo(day: day, type: .lunch),
            TypeInfo(day: day, type: .dinner)
        ]
    }
    
    var body: some View {
        VStack(alignment: .center) {
            HStack(spacing: 30) {
                ForEach(typeInfos) { type in
                    typeButton(type: type)
                }
            }
            .padding(.top, 8)
            
            PageView(currentPage: $viewModel.selectedPage, scroll: $viewModel.scroll, typeInfos.map{ $0.restaurantsView })
        }
        .background(Color.init("AppBackgroundColor"))
    }
}

// MARK: - Preview

struct DailyMenuView_Previews: PreviewProvider {
    static var previews: some View {
        DailyMenuView(.today)
            .environmentObject(AppState())
    }
}
