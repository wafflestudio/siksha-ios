//
//  TopPostCell.swift
//  Siksha
//
//  Created by 박정헌 on 2023/07/29.
//

import Foundation
import SwiftUI
struct TopPostCell:View{
    var title:String
    var content:String
    var like:Int
    var body:some View{
        HStack(alignment: .center){
            Text(title)
                .font(.custom("NanumSquareOTFB", size: 12))
            Spacer().frame(width:15)
            Text(content)
                .font(.custom("NanumSquareOTFR",size:12))
            Spacer()
            
            Image("like").padding(EdgeInsets(top: 0, leading: 0, bottom: 2, trailing: 0))
            
            Text("\(like)").foregroundColor(Color.init(red:1,green:149/255,blue:34/255))
                .font(.custom("Inter-ExtraLight",size:8))
        }

            .padding(EdgeInsets(top: 0, leading: 15, bottom: 0, trailing: 15))
            
    }
}
struct TopPostCell_Preview:PreviewProvider{
    static var previews:some View{
        TopPostCell(title: "제목", content: "본문 본문 본문", like: 3)
    }
}
