//
//  DevMenuView.swift
//  Siksha
//
//  Created by Jihyeon on 2/25/26.
//

import SwiftUI

struct DevMenuView: View {
    @State private var menuModels: [DailyMenuModel] = []
    @State private var isLoading: Bool = false
    
    private var menuString: String {
        if menuModels.isEmpty {
            return "메뉴 없음"
        } else {
            let menu = menuModels[0]
            return menu.description
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Button("Get today's menu\n(Test new menu repository)") {
                Task { @MainActor in
                    isLoading = true
                    let repo = MenuRepository()
                    menuModels = (try? await repo.getMenus(from: Date().yyyyMMdd, to: Date().yyyyMMdd)) ?? []
                    isLoading = false
                }
            }
            .buttonStyle(.bordered)
            
            ScrollView {
                VStack {
                    Spacer(minLength: 10)
                    if isLoading {
                        ActivityIndicator(isAnimating: .constant(true), style: .medium)
                    }
                    Text(menuString)
                        .lineLimit(nil)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 10)
                }
            }
            .frame(height: 300)
            .frame(maxWidth: .infinity)
            .background(Color.gray100)
        }
        .padding(20)
    }
}

private extension DailyMenuModel {
    var description: String {
        var desc = "\(date)\n"
        
        desc += "아침\n"
        for restaurant in breakfast {
            desc.append(restaurant.description)
        }
        
        desc += "점심\n"
        for restaurant in lunch {
            desc.append(restaurant.description)
        }
        
        desc += "저녁\n"
        for restaurant in dinner {
            desc.append(restaurant.description)
        }
        return desc
    }
}

private extension RestaurantModel {
    var description: String {
        var desc = "\(nameKr ?? "unknown") 메뉴\n"
        
        for menu in menus {
            desc.append(menu.description + "\n")
        }
        return desc
    }
}

private extension MenuModel {
    var description: String {
        "\(nameKr): \(price)원"
    }
}

#Preview {
    DevMenuView()
}
