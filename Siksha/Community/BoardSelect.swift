//
//  BoardSelect.swift
//  Siksha
//
//  Created by 박정헌 on 2023/07/29.
//

import Foundation
import SwiftUI
struct BoardSelect:View{
    var boardNames:[String]
    var body:some View{
        ScrollView(.horizontal,showsIndicators: false){
            HStack(alignment:.center,spacing: 10){
                ForEach(boardNames,id: \.self){name in
                    BoardNameCell(isSelected: true, boardName: name)
                }
            }
        }.padding(EdgeInsets(top: 23, leading: 28, bottom: 18, trailing: 28))
    }
}
struct BoardSelect_Preview:PreviewProvider{
    static var previews:some View{
        BoardSelect(boardNames: ["자유게시판","학식게시판","외식게시판","VS 게시판","베스트 메뉴 게시판","자유게시판","학식게시판","외식게시판","VS 게시판","베스트 메뉴 게시판"])
    }
}
