//
//  CommentCell.swift
//  Siksha
//
//  Created by 박정헌 on 2023/08/26.
//

import Foundation
import SwiftUI
struct Comment:Identifiable{
    var id = UUID()
    
    var userName:String
    var content:String
    var date:String
    var likeCount:Int
    var isLiked:Bool
}
struct CommentCell:View{
    var comment:Comment
    var body:some View{
        VStack(alignment:.leading,spacing:0){
            HStack(spacing:0) {
                Text(comment.userName)
                    .font(.custom("Inter-Regular",size:10))
                    .foregroundColor(.init("ReviewMediumColor"))
                
                Spacer()
                
                Text(comment.date)
                    .font(.custom("Inter-Regular", size: 8))
                    .frame(width:50, alignment: .trailing)
                    .foregroundColor(.init("ReviewLowColor"))
            }
            Spacer()
                .frame(height:8)
            Text(comment.content)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.init("ReviewHighColor"))
                
            Spacer()
                .frame(height:12)
            HStack(spacing:0){
                Image(comment.isLiked ? "PostLike-liked" : "PostLike-default")
                    .frame(width: 11.5, height: 11)
                    .padding(.init(top: 0, leading: 0, bottom: 4, trailing: 0))
                Spacer()
                    .frame(width:4)
                Text("\(comment.likeCount)")
                    .font(.custom("Inter-Regular", size: 8))
                    .foregroundColor(.init("MainThemeColor"))
                Spacer()
                Menu{
                    Button("취소", action: {})
                                  Button("신고하기", action: {})
                }
            label:{
                    Image("etc")
                        .frame(width:13,height:1.86)
                      
                }
                
            }
        }
        .padding(EdgeInsets(top: 12, leading: 35, bottom: 12, trailing: 35))
    }
}
struct CommentList:View{
    var comments:[Comment]
    var body: some View{
        VStack{
            ForEach(comments) { comment in
                CommentCell(comment: comment)
                Divider()
                
            }
        }
    }
}
struct CommentCell_preview:PreviewProvider{
    static var previews: some View{
       CommentList(comments: [
        Comment(userName: "username", content: "w: 305 본문 본문2", date: "23/09/27", likeCount: 2, isLiked: false),
        Comment(userName: "username", content: "본문 본문 본문 본문 본문 본문본문 본문 본문 본문 본문 본문본문 본문 본문 본문 본문 본문", date: "23/09/27", likeCount: 2, isLiked: false),
        Comment(userName: "username", content: "본문 본문3", date: "23/09/27", likeCount: 2, isLiked: false),
       ])
       .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro"))
    }
}

