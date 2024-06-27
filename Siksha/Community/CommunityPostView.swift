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
    @State private var isEditingPost = false
    @State private var needRefresh = false
    @Binding var needPostViewRefresh:Bool
    
    @State private var reportAlertIsShown = false
    @State private var reportCompleteAlertIsShown = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    let boardName: String
    
    var backButton: some View {
        Button(action: {
        needPostViewRefresh = true
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 7, height: 15)
        }
    }
    
    var imageSection: some View {
        Group {
            if let imageURLs = viewModel.postInfo.imageURLs {
                if #available(iOS 15.0, *) {
                    TabView {
                        ForEach(imageURLs, id: \.self) { imageURLString in
                            AsyncImage(url: URL(string: imageURLString)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            } placeholder: {
                                Color.gray
                            }
                            .frame(width: UIScreen.main.bounds.width * 0.9)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 300)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(imageURLs, id: \.self) {
                                imageURLString in
                                ThumbnailImage(imageURLString)
                            }
                        }
                    }
                }
            } else {
                EmptyView()
            }
        }
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
                CommentCell(comment: comment, viewModel: viewModel, reportCompleteAlertIsShown: $reportCompleteAlertIsShown, alertTitle: $alertTitle, alertMessage: $alertMessage)
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
        NavigationLink(
            destination: CommunityPostPublishView(
                needRefresh: self.$needRefresh, viewModel: CommunityPostPublishViewModel(
                    boardId: viewModel.postInfo.boardId,
                    communityRepository:DomainManager.shared.domain.communityRepository,
                    postInfo: viewModel.postInfo
                )
            ),
            isActive: $isEditingPost
        ) {
            EmptyView()
        }

        ZStack(alignment:.bottomTrailing) {
            ScrollView(.vertical, showsIndicators: false) {
                VStack {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(viewModel.postInfo.isAnonymous ? "익명" : "\(viewModel.postInfo.nickname ?? "")")
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
                                        isEditingPost = true
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
                                    Button("신고하기", action: {
                                        reportAlertIsShown = true
                                    })
                                }
                                Button("취소", action: {})
                            } label:{
                                Image("etc")
                                    .frame(width:13,height:13)
                            }
                            
                        }
                    }
                    .padding(EdgeInsets(top: 20, leading: 20, bottom: 10, trailing: 20))
                    
                    Divider()
                                     
                    commentList
                        .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
                    
                    Spacer()
                }
            }
            .onTapGesture {
                
                //  self.endTextEditing()
            }
            
            CommunityReplyBar(onCommentSubmit: { commentText,isAnonymous in
                viewModel.submitComment(postId: viewModel.postInfo.id, content: commentText,isAnonymous: isAnonymous)
            })
            
        }.customNavigationBar(title: boardName)
            .navigationBarItems(leading: backButton)
            .onAppear {
                viewModel.loadBasicInfos()
            }
            .textFieldAlert(isPresented: $reportAlertIsShown, title: "신고 사유", action: { reason in
                viewModel.reportPost(reason: reason ?? "") { success, errorMessage in
                    if success {
                        alertTitle = "신고"
                        alertMessage = "신고되었습니다."
                    } else {
                        alertTitle = "신고"
                        alertMessage = errorMessage ?? "신고에 실패했습니다."
                    }
                    reportAlertIsShown = false
                    reportCompleteAlertIsShown = true
                }
            })
            .alert(isPresented: $reportCompleteAlertIsShown, content: {
                Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            })

          
    }
    
}

extension View {
  func endTextEditing() {
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                    to: nil, from: nil, for: nil)
  }
}


/*struct CommunityPostView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityPostView(viewModel: StubCommunityPostViewModel(), boardName: StubCommunityViewModel().getSelectedBoardName(), needPostViewRefresh: <#Bool#>)
    }
}*/

class StubCommunityPostViewModel: CommunityPostViewModelType {
    @Published var reportAlert: Bool = false
    @Published var reportErrorAlert: Bool = false

    var reportAlertPublished: Published<Bool> { _reportAlert }
    var reportAlertPublisher: Published<Bool>.Publisher { $reportAlert }

    var reportErrorAlertPublished: Published<Bool> { _reportErrorAlert }
    var reportErrorAlertPublisher: Published<Bool>.Publisher { $reportErrorAlert }

    @Published var commentsListPublisher: [CommentInfo]
    @Published var hasNextPublisher: Bool

    init() {
        self.commentsListPublisher = [
            CommentInfo(content: "test1", likeCnt: 1, isLiked: true),
            CommentInfo(content: "test2", likeCnt: 0, isLiked: false)
        ]
        self.hasNextPublisher = false
        self.reportAlert = false
        self.reportErrorAlert = false
    }

    var postInfo: PostInfo {
        return PostInfo(
            title: "name",
            content: "content",
            isLiked: false,
            likeCount: 1,
            commentCount: 2,
            imageURLs: nil,
            isAnonymous: false,
            isMine: false
        )
    }

    func reportPost(reason: String, completion: @escaping (Bool, String?) -> Void) {
        self.reportAlert = true
        completion(true, nil)
    }

    func reportComment(commentId: Int, reason: String, completion: @escaping (Bool, String?) -> Void) {
        self.reportAlert = true
        completion(true, nil)
    }

    func editPost() {

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

    func submitComment(postId: Int, content: String, isAnonymous: Bool) {

    }

    func editComment(commentId id: Int, content: String) {

    }

    func deleteComment(id: Int) {

    }

    func toggleCommentLike(id: Int) {

    }
}
