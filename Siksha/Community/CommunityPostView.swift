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
    
    @State private var anonymousIsToggled = false
    @State private var commentContent: String = ""
    
    let boardName: String
    
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
        return EmptyView()
        /*if #available(iOS 15.0, *) {
            return ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(viewModel.postInfo.imageURL, id: \.self) {
                        imageURLString in
                        AsyncImage(url: URL(string: imageURLString))
                            .frame(width: 300, height: 300)
                    }
                }
            }
        } else {
            return ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(viewModel.postInfo.imageURL, id: \.self) {
                        imageURLString in
                        ThumbnailImage(imageURLString)
                    }
                }
            }
        }*/
    }
    
    var anonymousButton: some View {
        Button(action: {
                    anonymousIsToggled.toggle()
                    print(anonymousIsToggled)
                }) {
                    if anonymousIsToggled {
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
    
    var body: some View {
        ZStack(alignment:.bottomTrailing) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(viewModel.postInfo.userId)
                                .font(Font.custom("Inter-Regular",size:10))
                                .foregroundColor(.init("ReviewMediumColor"))
                            
                            Spacer()
                            
                            let formatter = RelativeDateTimeFormatter()
                            formatter.unitsStyle = .full
                            
                            let relativeDate = formatter.localizedString(for: viewModel.postInfo.createdAt, relativeTo: Date())

                            Text(relativeDate)
                                .font(Font.custom("Inter-Regular", size: 10))
                                .frame(alignment: .trailing)
                                .foregroundColor(Color("ReviewLowColor"))
                        }
                        
                        Text(viewModel.post.title)
                            .font(.custom("Inter-Bold", size: 14))
                        
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
                                Text(String(viewModel.post.likeCnt))
                                    .font(.custom("Inter-Regular", size: 9))
                                    .foregroundColor(Color("MainThemeColor"))
                            }
                            
                            HStack(alignment: .center) {
                                Image("Reply")
                                    .frame(width: 11.5, height: 11)
                                Spacer()
                                    .frame(width: 4)
                                Text(String(viewModel.post.commentCnt))
                                    .font(.custom("Inter-Regular", size: 9))
                                    .foregroundColor(Color.init("ReviewMediumColor"))
                                    .frame(height: 11, alignment: .center)
                            }
                            
                            Spacer()
                            
                            Menu{
                                if (UserManager.shared.userId == viewModel.postInfo.userId) {
                                    Button("수정", action: {
                                        
                                    })
                                    Button("삭제", action: {
                                    })
                                }
                                Button("취소", action: {})
                                Button("URL 복사하기", action: {})
                                if (UserManager.shared.userId != viewModel.postInfo.userId) {
                                    Button("신고하기", action: {})
                                }
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
            }
            .onTapGesture {

                  self.endTextEditing()
            }
            
            CommunityReplyBar()
                
        }.customNavigationBar(title: boardName)
            .navigationBarItems(leading: backButton)
            .onAppear {
                viewModel.loadBasicInfos()
            }
    }
}

extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
}


struct CommunityPostView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityPostView(viewModel: StubCommunityPostViewModel(), boardName: StubCommunityViewModel().getSelectedBoardName())
    }
}

class StubCommunityPostViewModel: CommunityPostViewModelType {
    @Published var commentsListPublisher: [CommentInfo]
    @Published var hasNextPublisher: Bool
    
    @Published private var post: Post
    
    init() {
        self.post = Post(id: 1, content: "Sample Post", isLiked: false, createdAt: Date(), likeCount: 10)
        self.commentsListPublisher = [
            CommentInfo(comment: Comment(id: 1, content: "Sample Comment", isLiked: false, createdAt: Date(), likeCount: 5))
            CommentInfo(comment: Comment(id: 1, content: "Sample Comment2", isLiked: true, createdAt: Date(), likeCount: 4))
        ]
        self.hasNextPublisher = false
    }
    
    var postInfo: PostInfo {
        return PostInfo(post: self.post)
    }

    func editPost() {
        // Implement with no-op or dummy functionality
    }

    func deletePost(completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func togglePostLike() {
        post.isLiked.toggle()
    }

    func loadBasicInfos() {

    }

    func loadMoreComments() {

    }

    func editComment(id: Int, content: String) {

    }

    func deleteComment(id: Int) {

    }

    func toggleCommentLike(id: Int) {

    }
}
