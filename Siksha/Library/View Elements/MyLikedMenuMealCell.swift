//
//  MyLikedMenuMealCell.swift
//  Siksha
//
//  Created by 박정헌 on 9/28/25.
//

import SwiftUI

struct MyLikedMenuMealCell: View {
    @ObservedObject var viewModel: MyLikedMenuViewModel
    let menu: MyLikedMenu
    var price = 0
    private var vegetarian: Bool = false
    private let orangeColor = Color.orange500
    private let grayColor = Color.gray900
    private let lightGrayColor = Color.gray700
    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let price = menu.price ?? 0
        let formattedNumber = price > 0 ? formatter.string(from: NSNumber(value: price)) : "-"

        return formattedNumber!
    }

    init(viewModel: MyLikedMenuViewModel, menu: MyLikedMenu) {
        self.viewModel = viewModel
        self.menu = menu
        if menu.etc.contains("No meat") {
            self.vegetarian = true
        }
        self.price = menu.price ?? 0
    }

    var body: some View {
        HStack(alignment: .top) {
            Text("\(menu.nameKr)")
                .multilineTextAlignment(.leading)
                .frame(maxWidth: 168, alignment: .leading)
                .customFont(font: .text15(weight: .Regular))
                .foregroundColor(.blackColor)

            if vegetarian {
                Image(.Icons.Common.vegan)
                    .resizable()
                    .renderingMode(.original)
                    .frame(width: 18, height: 18)
            }

            Spacer()
            if price < 10000 {
                Text(price > 0 ? String(formattedPrice) : "-")
                    .customFont(font: .text14(weight: .Regular))
                    .foregroundColor(.blackColor)
                    .frame(width: 38)
            } else {
                Text(price > 0 ? String(formattedPrice) : "-")
                    .customFont(font: .text14(weight: .Regular))
                    .foregroundColor(.blackColor)
            }
            Spacer()
                .frame(width: 16)
            Text(menu.reviewCnt > 0 ? String(format: "%.1f", menu.score ?? 0) : "-")
                .customFont(font: .text14(weight: .Regular))
                .foregroundColor(.blackColor)
                .frame(width: 23)

            Spacer()
                .frame(width: 16)

            Button(action: {
                viewModel.toggleMenu(menuId: menu.id)
            }) {
                Image(.Icons.Common.Heart.filled24)
                    .foregroundStyle(menu.isLiked ? Color.accentLike : Color.iconLike)
            }
            .disabled(viewModel.isUpdatingMenuLike(menuId: menu.id))
        }
        .padding(.zero)
        .background(Color.backgroundSecondary)
    }
}
