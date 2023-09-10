//
//  CommunityPostView.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/08/06.
//

import SwiftUI

struct CommunityPostView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @StateObject var viewModel: CommunityPostViewModel
    
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 7, height: 15)
        }
    }
    
    var imageSection: some View {
        if #available(iOS 15.0, *) {
            return ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.post.images, id: \.self) {
                        imageURLString in
                        AsyncImage(url: URL(string: imageURLString))
                            .frame(width: 300, height: 300)
                    }
                }
            }
        } else {
            return ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.post.images, id: \.self) {
                        imageURLString in
                        ThumbnailImage(imageURLString)
                    }
                }
            }
        }
    }
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text(viewModel.post.userName)
                            .font(Font.custom("Inter-Regular",size:10))
                            .foregroundColor(.init("ReviewMediumColor"))
                        
                        Spacer()
                        
                        Text(viewModel.postCreatedAtString)
                            .font(Font.custom("Inter-Regular", size: 10))
                            .frame(alignment: .trailing)
                            .foregroundColor(.init("ReviewLowColor"))
                    }
                    
                    Text(viewModel.post.title)
                        .font(.custom("Inter-Black", size: 14))
                    
                    Text(viewModel.post.content)
                        .font(.custom("Inter-Regular", size: 12))
                    
                    imageSection
                    
                    HStack {
                        HStack(alignment: .center) {
                            Image(viewModel.post.isLiked ? "PostLike-liked" : "PostLike-default")
                                .frame(width: 11.5, height: 10)
                                .padding(.init(top: 0, leading: 0, bottom: 1.56, trailing: 0))
                            Spacer()
                                .frame(width: 4)
                            Text(String(viewModel.post.likeCount))
                                .font(.custom("Inter-Regular", size: 9))
                                .foregroundColor(Color("MainThemeColor"))
                        }
                        
                        HStack(alignment: .center) {
                            Image("reply")
                                .frame(width: 11.5, height: 11)
                            Spacer()
                                .frame(width: 4)
                            Text(String(viewModel.post.replyCount))
                                .font(.custom("Inter-Regular", size: 9))
                                .foregroundColor(Color.init("ReviewMediumColor"))
                                .frame(height: 11, alignment: .center)
                        }
                        
                        Spacer()
                        
                        Menu{
                            Button("취소", action: {})
                            Button("URL 복사하기", action: {})
                            Button("신고하기", action: {})
                        } label:{
                            Image("etc")
                                .frame(width:13,height:13)
                        }
                        
                    }
                }
                .padding(EdgeInsets(top: 20, leading: 30, bottom: 10, trailing: 30))
                
                Divider()
                
                CommentList(comments: viewModel.post.comments)
                
                Spacer()
            }
        } .customNavigationBar(title: viewModel.post.boardName)
            .navigationBarItems(leading: backButton)
            .onAppear {
                viewModel.loadImages()
                viewModel.post.loadComments()
            }
    }
}

struct CommunityPostView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityPostView(viewModel: CommunityPostViewModel(post: CommunityPost(title: "name", content: "how", userName: "abc" , boardName: "자유게시판", isLiked: true, likeCount: 12, replyCount: 23)))
    }
}
