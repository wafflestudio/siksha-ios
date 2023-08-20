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
    @State
    var tag:Int? = nil
    let dividerColor = Color("ReviewLowColor")
    let boards:[String] = ["자유게시판","학식게시판","vs 게시판"]
    let topPosts:[CommunityPost] = []
    let contents: [CommunityPost] = [
        CommunityPost(title: "name", content: "how", userLikes: true, likeCount: 12, replyCount: 23),
        CommunityPost(title: "hello", content: "what", userLikes: false, likeCount: 12, replyCount: 23),
        CommunityPost(title: "world", content: "why", userLikes: false, likeCount: 12, replyCount: 23),
        CommunityPost(title: "hello bye", content: "who", userLikes: false, likeCount: 12, replyCount: 23),
        CommunityPost(title: "hello bye", content: "who", userLikes: false, likeCount: 12, replyCount: 23),
        CommunityPost(title: "hello bye", content: "who", userLikes: false, likeCount: 12, replyCount: 23),
        CommunityPost(title: "name", content: "how", userLikes: true, likeCount: 12, replyCount: 23),
        CommunityPost(title: "hello", content: "what", userLikes: false, likeCount: 12, replyCount: 23),
        CommunityPost(title: "world", content: "why", userLikes: false, likeCount: 12, replyCount: 23),
        CommunityPost(title: "hello bye", content: "who", userLikes: false, likeCount: 12, replyCount: 23),
        CommunityPost(title: "hello bye", content: "who", userLikes: false, likeCount: 12, replyCount: 23),
        CommunityPost(title: "hello bye", content: "who", userLikes: false, likeCount: 12, replyCount: 23)
    ]
  

    var body: some View {
        NavigationView {
            ZStack(alignment:.bottomTrailing){
                VStack(spacing:0){
                    BoardSelect(boardNames: boards)
                    divider
                    TopPosts(content: [
                        CommunityPost(title: "post1", content: "content1", userLikes: true, likeCount: 2, replyCount: 3),
                        CommunityPost(title: "post2", content: "content2", userLikes: true, likeCount: 2, replyCount: 3),
                        CommunityPost(title: "post3", content: "content3", userLikes: true, likeCount: 2, replyCount: 3)
                    ])
                    
                    ScrollView{
                        divider
                        postList
                    }
                    
                }
                
                .customNavigationBar(title: "icon")
                Button{
                    self.tag = 1
                }label:{
                    Image("writeButton")
                        .frame(width:44,height:44)
                        .background(Color.init("MainThemeColor"))
                
                        .clipShape(Circle())
                }
                .offset(x:-30,y:-22)
                NavigationLink(destination:CommunityPostPublishView(),tag:1,selection:self.$tag){
                    EmptyView()
                }
            }
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
    var writeButton: some View{
        Image("writeButton")
    }
}

struct CommunityPostPreView: View {
    private let contentColor = Color("ReviewHighColor")
    private let likeColor = Color("MainThemeColor")
    private let replyColor = Color("ReviewMediumColor")
    private let defaultImageColor = Color("DefaultImageColor")
    
    
    let content: CommunityPost
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(content.title)
                    .font(.custom("Inter-Bold", size: 15))
                Spacer()
                    .frame(width: 10)
                Text(content.content)
                    .font(.custom("Inter-ExtraLight", size: 12))
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
                            .font(.custom("Inter-Regular", size: 9))
                            
                            .foregroundColor(likeColor)
                    }
                    HStack(alignment: .center) {
                        Image("reply")
                            .frame(width: 11.5, height: 11)
                        Spacer()
                            .frame(width: 4)
                        Text(String(content.replyCount))
                            .font(.custom("Inter-Regular", size: 9))
                            .foregroundColor(Color.init("ReviewMediumColor"))
                            .frame(height: 11, alignment: .center)
                        
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
