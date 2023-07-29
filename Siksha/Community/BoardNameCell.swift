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
    let unSelectedBackgroundColor =  Color(red:242/255, green:242/255, blue:242/255,opacity:1)

    let selectedFontColor = Color.white
    let unSelectedFontColor = Color (red:183/255, green:183/255, blue:183/255,opacity: 1);

    
   @State var isSelected:Bool
    var boardName:String
    
    var body: some View{
        Text(boardName)
             .font(.custom("NanumSquareOTFR", size: 15))
            .padding(EdgeInsets(top: 9, leading: 12, bottom: 9, trailing: 12))
            .background(isSelected ? selectedBackgroundColor : unSelectedBackgroundColor)
            .foregroundColor(isSelected ? selectedFontColor : unSelectedFontColor)
            .cornerRadius(16)
            .onTapGesture {
                
                isSelected.toggle()
            }
          
    }
    
}
struct BoardNameCell_Previews: PreviewProvider {
    static var previews: some View {
        BoardNameCell(isSelected: true, boardName: "자유게시판")
    }
}
