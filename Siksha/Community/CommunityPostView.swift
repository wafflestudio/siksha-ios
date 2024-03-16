//
//  CommunityPostView.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/08/06.
//

import SwiftUI

struct CommunityPostView<ViewModel>: View where ViewModel: CommunityPostViewModelType {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @ObservedObject var viewModel: ViewModel
    
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
    
    var relativeDate: String {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .full
            return formatter.localizedString(for: viewModel.postInfo.createdAt, relativeTo: Date())
    }
    
    var commentList: some View {
        LazyVStack(spacing:0){
            ForEach(viewModel.commentsListPublisher) { comment in
                CommentCell(comment: comment, viewModel: viewModel)
                Divider()
            }
            
            if self.viewModel.hasNextPublisher == true {
                HStack {
                    Spacer()
                    ProgressView()
                        .onAppear {
                            self.viewModel.loadMoreComments()
                        }
                    Spacer()
                }
                .frame(height: 40)
            }
        }
    }
    
    var body: some View {
        ZStack(alignment:.bottomTrailing) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(viewModel.postInfo.isAnonymous ? "익명" : "\(viewModel.postInfo.nickname!)")
                                .font(Font.custom("Inter-Regular",size:10))
                                .foregroundColor(.init("ReviewMediumColor"))
                            
                            Spacer()
                            
                            Text(relativeDate)
                                .font(Font.custom("Inter-Regular", size: 10))
                                .frame(alignment: .trailing)
                                .foregroundColor(Color("ReviewLowColor"))
                        }
                        
                        Text(viewModel.postInfo.title)
                            .font(.custom("Inter-Bold", size: 14))
                        
                        Text(viewModel.postInfo.content)
                            .font(.custom("Inter-Regular", size: 12))
                        
                        imageSection
                        
                        HStack {
                            HStack(alignment: .center) {
                                Button(action: {
                                    viewModel.togglePostLike()
                                }) {
                                    Image(viewModel.postInfo.isLiked ? "PostLike-liked" : "PostLike-default")
                                        .frame(width: 11.5, height: 10)
                                        .padding(.init(top: 0, leading: 0, bottom: 1.56, trailing: 0))
                                }
                                Spacer()
                                    .frame(width: 4)
                                Text(String(viewModel.postInfo.likeCount))
                                    .font(.custom("Inter-Regular", size: 9))
                                    .foregroundColor(Color("MainThemeColor"))
                            }
                            
                            HStack(alignment: .center) {
                                Image("Reply")
                                    .frame(width: 11.5, height: 11)
                                Spacer()
                                    .frame(width: 4)
                                Text(String(viewModel.postInfo.commentCount))
                                    .font(.custom("Inter-Regular", size: 9))
                                    .foregroundColor(Color.init("ReviewMediumColor"))
                                    .frame(height: 11, alignment: .center)
                            }
                            
                            Spacer()
                            
                            Menu{
                                if (viewModel.postInfo.isMine) {
                                    Button("수정", action: {
                                        
                                    })
                                    Button("삭제", action: {
                                        viewModel.deletePost { success in
                                            if success {
                                                self.presentationMode.wrappedValue.dismiss()
                                            } else {
                                            
                                            }
                                        }
                                    })
                                }
                                Button("URL 복사하기", action: {})
                                if (UserManager.shared.nickname != viewModel.postInfo.nickname) {
                                    Button("신고하기", action: {})
                                }
                                Button("취소", action: {})
                            } label:{
                                Image("etc")
                                    .frame(width:13,height:13)
                            }
                            
                        }
                    }
                    .padding(EdgeInsets(top: 20, leading: 30, bottom: 10, trailing: 30))
                    
                    Divider()
                                     
                    commentList
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
                    
                    Spacer()
                }
            }
            .onTapGesture {

                  self.endTextEditing()
            }
            
            CommunityReplyBar(onCommentSubmit: { commentText in
                viewModel.submitComment(postId: viewModel.postInfo.id, content: commentText)
            })
                
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
    
    init() {
        self.commentsListPublisher = [
            CommentInfo(content: "test1", likeCnt: 1, isLiked: true),
            CommentInfo(content: "test2", likeCnt: 0, isLiked: false)
        ]
        self.hasNextPublisher = false
    }
    
    var postInfo: PostInfo {
        return PostInfo(title: "name",
                    content: "content",
                    isLiked: false,
                    likeCount: 1,
                    commentCount: 2,
                    imageURL: "",
                    isAnonymous: false,
                    isMine: false)
    }

    func editPost() {
        // Implement with no-op or dummy functionality
    }

    func deletePost(completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func togglePostLike() {
        
    }

    func loadBasicInfos() {

    }

    func loadMoreComments() {

    }
    
    func submitComment(postId: Int, content: String) {
        
    }

    func editComment(commentId id: Int, content: String) {

    }

    func deleteComment(id: Int) {

    }

    func toggleCommentLike(id: Int) {

    }
}
