//
//  ComunityView.swift
//  Siksha
//
//  Created by 김령교 on 7/29/23.
//

import SwiftUI

struct CommunityPost: Identifiable, Equatable {
    let id: UUID = UUID()
    let title: String
    let content: String
    let userLikes: Bool
    let likeCount: Int
    let replyCount: Int
    let image: Image? = nil
}

struct CommunityView: View {
    let dividerColor = Color(red: 183/255, green: 183/255, blue: 183/255, opacity: 1)
    
    let contents: [CommunityPost] = [
        CommunityPost(title: "name", content: "how", userLikes: true, likeCount: 12, replyCount: 23),
        CommunityPost(title: "hello", content: "what", userLikes: false, likeCount: 12, replyCount: 23),
        CommunityPost(title: "world", content: "why", userLikes: false, likeCount: 12, replyCount: 23),
        CommunityPost(title: "hello bye", content: "who", userLikes: false, likeCount: 12, replyCount: 23),
        CommunityPost(title: "hello bye", content: "who", userLikes: false, likeCount: 12, replyCount: 23),
        CommunityPost(title: "hello bye", content: "who", userLikes: false, likeCount: 12, replyCount: 23)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView{
                divider
                postList
            }
            .customNavigationBar(title: "icon")
        }
    }
    
    var divider: some View {
        Divider()
            .foregroundColor(dividerColor)
    }
    
    var postList: some View {
        LazyVStack(spacing: 0) {
            ForEach(contents) { content in
                CommunityPostPreView(content: content)
                divider
            }
        }
    }
}

struct CommunityPostPreView: View {
    private let contentColor = Color(red: 57/255, green: 57/255, blue: 57/255, opacity: 1)
    private let likeColor = Color("MainThemeColor")
    private let replyColor = Color(red: 121/255, green: 121/255, blue: 121/255, opacity: 1)
    private let defaultImageColor = Color(red: 217/255, green: 217/255, blue: 217/255, opacity: 1)
    
    
    let content: CommunityPost
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(content.title)
                    .font(.custom("NanumSquareOTFB", size: 15))
                Spacer()
                    .frame(width: 10)
                Text(content.content)
                    .font(.custom("NanumSquareOTF", size: 12))
                    .foregroundColor(contentColor)
                Spacer()
                    .frame(width: 10)
                HStack {
                    HStack(alignment: .center) {
                        Image(content.userLikes ? "PostLike-liked" : "PostLike-default")
                            .frame(width: 11.5, height: 10)
                            .padding(.init(top: 0, leading: 0, bottom: 1.56, trailing: 0))
                        Spacer()
                            .frame(width: 4)
                        Text(String(content.likeCount))
                            .font(.custom("NanumSquareOTF", size: 9))
                            
                            .foregroundColor(likeColor)
                    }
                    HStack(alignment: .center) {
                        Image("reply")
                            .frame(width: 11.5, height: 11)
                        Spacer()
                            .frame(width: 4)
                        Text(String(content.replyCount))
                            .font(.custom("NanumSquareOTF", size: 9)).frame(height: 11, alignment: .center)
                        
                    }
                }
            }
            Spacer()
            Rectangle()
                .frame(width: 61, height: 61)
                .foregroundColor(defaultImageColor)
        }
        .padding(EdgeInsets(top: 15, leading: 35, bottom: 15, trailing: 21))
    }
}

struct ComunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView()
    }
}
