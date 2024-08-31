//
//  BoardNameCell.swift
//  Siksha
//
//  Created by 박정헌 on 2023/07/29.
//

import Foundation
import SwiftUI
struct BoardNameCell: View{
    let selectedBackgroundColor = Color.init("MainThemeColor")
    let unSelectedBackgroundColor =  Color.init("UnselectedBoardColor")

    let selectedFontColor = Color.white
    let unSelectedFontColor = Color.init("ReviewLowColor")

    var isSelected: Bool
    var boardName: String
    
    var body: some View{
        Text(boardName)
            .font(.custom("NanumSquareOTFB", size: 15))
            .padding(EdgeInsets(top: 9, leading: 12, bottom: 9, trailing: 12))
            .background(isSelected ? selectedBackgroundColor : unSelectedBackgroundColor)
            .foregroundColor(isSelected ? selectedFontColor : unSelectedFontColor)
            .cornerRadius(16)
    }
    
}
struct BoardNameCell_Previews: PreviewProvider {
    static var previews: some View {
        BoardNameCell(isSelected: true, boardName: "자유게시판")
    }
}
