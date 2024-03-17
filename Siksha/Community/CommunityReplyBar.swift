//
//  CommunityReplyBar.swift
//  Siksha
//
//  Created by 김령교 on 8/27/23.
//

import SwiftUI

struct CommunityReplyBar: View {
    @State var commentText: String = ""
    @State var isAnonymous:Bool = false
    var onCommentSubmit: (String,Bool) -> Void
    
    let dividerColor = Color(red: 183/255, green: 183/255, blue: 183/255, opacity: 1)
    let replyColor = Color(red: 248/255, green: 248/255, blue: 248/255, opacity: 1)
    
    var body: some View {
        ZStack{
            Rectangle()
                .fill(Color.white)
                .frame(height: 40)
            
            RoundedRectangle(cornerRadius: 12)
                .fill(replyColor)
                .frame(maxWidth: .infinity, maxHeight: 37)
                .overlay(
                    HStack {
                        anonymousButton
                            .padding(EdgeInsets(top: 5, leading: 12, bottom: 5, trailing: 6))
                        TextField("내용을 입력하세요", text: $commentText)
                        Button(action: {
                            onCommentSubmit(commentText,isAnonymous)
                            commentText = ""
                        }){
                            Image("Upload")
                        }
                        .padding(EdgeInsets(top: 5, leading: 6, bottom: 5, trailing: 12))
                    }
                )
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 5, trailing: 16))
        }
    }
    var anonymousButton: some View {
        Button(action: {
            isAnonymous.toggle()
                }) {
                    if isAnonymous {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15.0)
                                .fill(Color("MainThemeColor"))
                                .frame(width: 34, height: 25)
                            Text("익명")
                                .font(.custom("Inter-SemiBold", size: 12))
                                .foregroundColor(Color.white)
                        }
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 15.0)
                                .stroke(Color("MainThemeColor"))
                                .frame(width: 34, height: 25)
                            Text("익명")
                                .font(.custom("Inter-SemiBold", size: 12))
                                .foregroundColor(Color("MainThemeColor"))
                        }
                    }
                }
    }
}

struct CommunityReplyBar_Previews: PreviewProvider {
    static var previews: some View {
        CommunityReplyBar(onCommentSubmit: { commentText,isAnonymous in
            print("Comment submitted: \(commentText)\nisAnonymous: \(isAnonymous)")
        })
    }
}
