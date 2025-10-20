//
//  BoardNameCell.swift
//  Siksha
//
//  Created by 박정헌 on 2023/07/29.
//

import SwiftUI

struct BoardNameCell: View{
    var isSelected: Bool
    var boardName: String
    
    private var backgroundColor: Color {
        isSelected ? .orange500 : .gray100
    }
    
    private var nameColor: Color {
        isSelected ? .textButton : .textBubble
    }
    
    var body: some View{
        Text(boardName)
            .customFont(font: .text15(weight: .Bold))
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(backgroundColor)
            .foregroundColor(nameColor)
            .cornerRadius(12)
    }
    
}

#Preview {
    BoardNameCell(isSelected: true, boardName: "자유 게시판")
    BoardNameCell(isSelected: false, boardName: "리뷰 게시판")
}
