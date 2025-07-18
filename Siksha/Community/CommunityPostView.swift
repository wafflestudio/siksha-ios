//
//  CommunityPostView.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/08/06.
//

import SwiftUI
import Kingfisher

struct CommunityPostView<ViewModel>: View where ViewModel: CommunityPostViewModelType {
    enum chosenType:Identifiable{
        var id:Int{
            switch self{
            case .post(let post):
                return post.id
            case .comment(let comment):
                return -comment.id
            }
    
        }
        
      
        
        case post(post:PostInfo)
        case comment(comment:CommentInfo)
    }
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: ViewModel
    
    @State private var anonymousIsToggled = false
    @State private var commentContent: String = ""
    @State private var isEditingPost = false
    @State private var needRefresh = false
    @State private var imageIndex = 0
    @State private var showImages = false
    @State private var showAlert:chosenType? = nil
    @State private var showPostMenu = false
    @State private var showPostDeleteAlert = false
    @State private var editComment:CommentInfo? = nil
    @State private var deleteCommentId = 0
    @State private var showActionSheet:chosenType? = nil
    @Binding var needPostViewRefresh:Bool
    
    var backButton: some View {
        Button(action: {
            needPostViewRefresh = true
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 7, height: 15)
                .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 30))
        }
        .contentShape(Rectangle())
    }
    
    var imageSection: some View {
        Group {
            if let imageURLs = viewModel.postInfo.imageURLs {
                ZStack(alignment:.topTrailing){
                    Text("\(imageIndex + 1)/\(imageURLs.count)")
                        .frame(width:28,height: 17)
                        .background(Color("Gray400"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .font(.custom("NanumSquareOTFR", size: 10))
                        .offset(x: -15,y: 15)
                        .zIndex(1)
                    
                        TabView(selection:$imageIndex) {
                            ForEach(Array(imageURLs.enumerated()), id: \.0) { index,imageURLString in
                                AsyncImage(url: URL(string: imageURLString)) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    Color.white
                                }
                                .frame(width: UIScreen.main.bounds.width * 0.9)
                                .tag(index)
                                .onTapGesture {
                                    showImages = true
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 300)
                }
            } else {
                EmptyView()
            }
        }
    }
        
    var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: viewModel.postInfo.createdAt, relativeTo: Date())
    }
    
    var postHeader:some View{
        HStack{
            if let profileUrl = viewModel.postInfo.profileUrl {
                KFImage(URL(string:profileUrl))
                    .resizable()
                    .frame(width: 33,height:33)
                    .clipShape(Circle())
            }
            else{
                Image("LogoEllipse")
                    .resizable()
                    .frame(width: 33,height:33)
                    .clipShape(Circle())
            }
            
            VStack(alignment: .leading){
                Text(viewModel.postInfo.isAnonymous ? "익명" : "\(viewModel.postInfo.nickname ?? "")")
                    .font(Font.custom("NanumSquareOTFB", size: 11))
                Text(relativeDate)
                    .font(Font.custom("NanumSquareOTFR", size: 10))
                    .foregroundColor(Color("Gray600"))
            }
            Spacer()
            /*Menu{
             if (viewModel.postInfo.isMine) {
             Button("수정", action: {
             isEditingPost = true
             })
             Button("삭제", action: {
             viewModel.deletePost { success in
             if success {
             self.needPostViewRefresh = true
             
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
             }*/
            Image("etc")
                .frame(width:13,height:13)
                .padding(EdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0))
                .onTapGesture {
                    showActionSheet = .post(post:viewModel.postInfo)
                }
        }.padding(EdgeInsets(top: 16, leading: 21, bottom: 0, trailing: 19))
    }
    var likeButton: some View{
        Button(action: {
            viewModel.togglePostLike()
        }) {
                Image(viewModel.postInfo.isLiked ? "LikeButton-liked" : "LikeButton-default")
          
        }
    }
    var commentList: some View {
        LazyVStack(spacing:0){
            ForEach(viewModel.commentsListPublisher) { comment in
                CommentCell(comment: comment, viewModel: viewModel,onMenuPressed: {
                    showActionSheet = .comment(comment: comment)
                    commentContent = comment.content
                })
              
                    
                Divider()
                    .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 0, trailing: 7.5))
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
        .errorAlert(error: $viewModel.error)
    }
  

    var postDeleteAlert: some View{
        VStack(spacing:0){
            Spacer()
                .frame(height:18.34)
            Text("게시글 삭제")
                .font(.custom("Inter-SemiBold", size: 16))
            Spacer()
                .frame(height:10.23)
            Text("게시글을 정말 삭제하시겠습니까?")
                .font(.custom("Inter-Regular", size: 12))
            Spacer()
                .frame(height:16.84)
            Divider()
            HStack(spacing:0){
                Button(action:{showPostDeleteAlert = false},label:{Text("취소")
                        .font(.custom("Inter-Bold", size: 16))
                    .frame(maxWidth:.infinity)})
                .foregroundColor(Color("Orange500"))
                .frame(maxWidth: .infinity,alignment: .center)
                Divider()
                Button(action:{
                    viewModel.deletePost { success in
                        if success {
                            self.needPostViewRefresh = true
                            self.presentationMode.wrappedValue.dismiss()
                        } else {
                            
                        }
                    }
                },label:{Text("삭제")    .font(.custom("Inter-Regular", size: 16))
                    .frame(maxWidth:.infinity)})
                .frame(maxWidth: .infinity,alignment: .center)
                
                
                
            }
        }.frame(height:130.27,alignment: .center)
        
    }
    var commentDeleteAlert: some View{
        VStack(spacing:0){
            Spacer()
                .frame(height:18.34)
            Text("댓글 삭제")
                .font(.custom("Inter-SemiBold", size: 16))
            Spacer()
                .frame(height:10.23)
            Text("댓글을 정말 삭제하시겠습니까?")
                .font(.custom("Inter-Regular", size: 12))
            Spacer()
                .frame(height:16.84)
            Divider()
            HStack(spacing:0){
                Button(action:{deleteCommentId = -1
                },label:{Text("취소")
                        .font(.custom("Inter-Bold", size: 16))
                    .frame(maxWidth:.infinity)})
                .foregroundColor(Color("Orange500"))
                .frame(maxWidth: .infinity,alignment: .center)
                Divider()
                Button(action:{
                    viewModel.deleteComment(id:deleteCommentId){completion in
                        viewModel.loadBasicInfos()
                        deleteCommentId = -1
                    }
                },label:{Text("삭제")    .font(.custom("Inter-Regular", size: 16))
                    .frame(maxWidth:.infinity)})
                .frame(maxWidth: .infinity,alignment: .center)
                
                
                
            }
        }.frame(height:130.27,alignment: .center)
           
        
    }
    var body: some View {
        /*NavigationLink(
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
        }*/
        
        ZStack(alignment:.bottomTrailing) {
            VStack(spacing: 0){
                
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing:0) {
                        postHeader
                        VStack(alignment: .leading) {
                            
                            Text(viewModel.postInfo.title)
                                .font(.custom("NanumSquareOTFEB", size: 16))
                            Spacer()
                                .frame(height:12)
                            Text(viewModel.postInfo.content)
                                .font(.custom("NanumSquareOTFR", size: 12))
                            Spacer()
                                .frame(height:19)
                            imageSection
                            
                            Spacer()
                                .frame(height: viewModel.postInfo.imageURLs?.isEmpty ?? true ? 1 : 12.5)
                            HStack {
                                HStack(alignment: .center) {
                                    
                                    Image(viewModel.postInfo.isLiked ? "PostLike-liked" : "PostLike-default")
                                        .frame(width: 11.5, height: 10)
                                        .padding(.init(top: 0, leading: 0, bottom: 1.56, trailing: 0))
                                    
                                    Spacer()
                                        .frame(width: 4)
                                    Text(String(viewModel.postInfo.likeCount))
                                        .font(.custom("Inter-Regular", size: 10))
                                        .foregroundColor(Color("Orange500"))
                                }
                                
                                HStack(alignment: .center) {
                                    Image("Comment")
                                        .frame(width: 11.5, height: 11)
                                    Spacer()
                                        .frame(width: 4)
                                    Text(String(viewModel.postInfo.commentCount))
                                        .font(.custom("Inter-Regular", size: 10))
                                        .foregroundColor(Color.init("Gray700"))
                                        .frame(height: 11, alignment: .center)
                                }
                                
                                Spacer()
                                
                                
                                
                            }.padding(EdgeInsets(top: 0, leading: 1.5, bottom: 0, trailing: 0))
                            Spacer()
                                .frame(height:14)
                            likeButton
                            
                        }
                        .padding(EdgeInsets(top: 15, leading: 22, bottom: 12.5, trailing: 19))
                        
                        Divider()
                            .foregroundColor(Color("Low"))
                            .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 0, trailing: 7.5))

                        commentList
                            .padding(EdgeInsets(top: 0, leading: 0, bottom: 30, trailing: 0))
                        
                        Spacer()
                    }
                    .edgesIgnoringSafeArea(.top)
                }
                .onTapGesture {
                    self.endTextEditing()
                }
            }
            .padding(.bottom, 20)
            
            ZStack {
                Rectangle()
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .foregroundColor(.white)

                CommunityReplyBar(onCommentSubmit: { commentText, isAnonymous in
                    viewModel.submitComment(postId: viewModel.postInfo.id, content: commentText, isAnonymous: isAnonymous)
                })
            }
            .ignoresSafeArea(edges: .bottom)


          
                if(showPostDeleteAlert){
                    Color.black.opacity(0.4)
                        .ignoresSafeArea(.all)
                        .onTapGesture {
                            showPostDeleteAlert = false
                        }
                    ZStack(alignment: .center){
                        postDeleteAlert
                            .background(Color.white)
                            .cornerRadius(26)
                        
                    }.frame(maxWidth:.infinity,maxHeight: .infinity)
                        .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                       
                }
            if(deleteCommentId > 0){
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        deleteCommentId = -1
                    }
                ZStack(alignment: .center){
                    commentDeleteAlert
                        .background(Color.white)
                        .cornerRadius(26)
                    
                }.frame(maxWidth:.infinity,maxHeight: .infinity)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                   
            }
         
                
            }
            .customNavigationBar(title: viewModel.boardNamePublisher)
                .navigationBarItems(leading: backButton)
                .actionSheet(item:$showActionSheet){item in
                    switch(item){
                    case .post(let post):
                        let editButton = ActionSheet.Button.default(Text("수정"), action: {
                                    isEditingPost = true
                                    showPostMenu = false
                                })
                                let deleteButton = ActionSheet.Button.default(Text("삭제"), action: {
                                    showPostMenu = false
                                        showPostDeleteAlert = true
                                })
                                let reportButton = ActionSheet.Button.default(Text("신고"), action: {
                                    showPostMenu = false
                                    showAlert = item
                                })
                                if(viewModel.postInfo.isMine){
                                    return ActionSheet(title: Text("게시글 메뉴"), buttons: [
                                       editButton,deleteButton,
                                        .cancel(Text("취소"))
                                    ])
                                }
                                else{
                                    return ActionSheet(title: Text("게시글 메뉴"), buttons: [
                                       reportButton,
                                        .cancel(Text("취소"))
                                    ])
                                }
                    case .comment(let comment):
                        let editButton = ActionSheet.Button.default(Text("수정"), action: {
                                    editComment = comment
                                    showActionSheet = nil
                                })
                                let deleteButton = ActionSheet.Button.default(Text("삭제"), action: {
                                    deleteCommentId = comment.id
                                    showActionSheet = nil
                                })
                                let reportButton = ActionSheet.Button.default(Text("신고"), action: {
                                    showAlert = item

                                })
                        if(comment.isMine){
                                    return ActionSheet(title: Text("댓글 메뉴"), buttons: [
                                       editButton,deleteButton,
                                        .cancel(Text("취소"))
                                    ])
                                }
                                else{
                                    return ActionSheet(title: Text("댓글 메뉴"), buttons: [
                                       reportButton,
                                        .cancel(Text("취소"))
                                    ])
                                }
                    }
                }
               
                .fullScreenCover(isPresented: $isEditingPost){
                    CommunityPostPublishView(
                        needRefresh: self.$needRefresh, needPostViewRefresh: self.$needPostViewRefresh, viewModel: CommunityPostPublishViewModel(
                            boardId: viewModel.postInfo.boardId,
                            communityRepository:DomainManager.shared.domain.communityRepository,
                            postInfo: viewModel.postInfo
                        )
                    )
                }
                .fullScreenCover(isPresented: $showImages){
                    ImageView(viewModel: viewModel, imageIndex: imageIndex)
                    
                }
                .fullScreenCover(item: $showAlert){item in
                    switch item{
                    case .post:
                        AlertView(RenewalSettingsViewModel(), viewModel,commentId: nil)
                    case .comment(let comment):
                        AlertView(RenewalSettingsViewModel(),viewModel,commentId: comment.id)
                    }
                }
                .fullScreenCover(item:$editComment) {comment in
                    EditCommentView( editedContent: comment.content, onSave: { newContent in
                        viewModel.editComment(commentId: comment.id, content: newContent)
                        editComment = nil
                    }, onCancel: {
                        editComment = nil
                    })
                }
                
                .refreshable {
                    await viewModel.asyncRefresh()
                }
            
            
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
 CommunityPostView(viewModel: StubCommunityPostViewModel(), boardName: StubCommunityViewModel().getSelectedBoardName(), needPostViewRefresh:)
 }
 }*/

class StubCommunityPostViewModel: CommunityPostViewModelType {
    var error: AppError?
    
    func asyncRefresh() async {
        
    }
    
    func deleteComment(id: Int, completion: @escaping (Bool) -> Void) {
        
    }
    
    
    var boardNamePublisher: String
    
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
        self.boardNamePublisher = "board"
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
