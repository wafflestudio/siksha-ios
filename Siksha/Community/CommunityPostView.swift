//
//  CommunityPostView.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/08/06.
//

import SwiftUI
import Kingfisher

struct CommunityPostView<ViewModel>: View where ViewModel: CommunityPostViewModelType {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject var appState: AppState
    @ObservedObject var viewModel: ViewModel
    
    @State private var anonymousIsToggled = false
    @State private var commentContent: String = ""
    @State private var isEditingPost = false
    @State private var needRefresh = false
    @State private var imageIndex = 0
    @State private var showImages = false
    @State private var showAlert = false
    @State private var showPostMenu = false
    @State private var showPostDeleteAlert = false
    @State private var showCommentMenu = false
    @State private var showCommentId = 0
    @State private var showCommentEditView = false
    @State private var showCommentMine = false
    @State private var showCommentDeleteAlert = false
    @Binding var needPostViewRefresh:Bool
    
    @State private var reportAlertIsShown = false
    @State private var reportCompleteAlertIsShown = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    var backButton: some View {
        Button(action: {
            needPostViewRefresh = true
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 7, height: 15)
                .padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
        }
        .contentShape(Rectangle())
    }
    
    var imageSection: some View {
        Group {
            if let imageURLs = viewModel.postInfo.imageURLs {
                ZStack(alignment:.topTrailing){
                    Text("\(imageIndex + 1)/\(imageURLs.count)")
                        .frame(width:28,height: 17)
                        .background(Color("LightFontColor"))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .font(.custom("NanumSquareOTFRegular", size: 10))
                        .offset(x: -15,y: 15)
                        .zIndex(1)
                    
                    
                    if #available(iOS 15.0, *) {
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
                    .font(Font.custom("NanumSquareOTFBold", size: 11))
                Text(relativeDate)
                    .font(Font.custom("NanumSquareOTFRegular", size: 10))
                    .foregroundColor(Color("ReviewLowColor"))
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
                .onTapGesture {
                    showPostMenu = true
                }
        }.padding(EdgeInsets(top: 16, leading: 21, bottom: 0, trailing: 19))
    }
    var likeButton: some View{
        Button(action: {
            viewModel.togglePostLike()
        }) {
            HStack{
                Image(viewModel.postInfo.isLiked ? "PostLike-liked" : "PostLike-default")
                    .frame(width:11.5,height: 11)
                Spacer()
                    .frame(width: 5)
                Text("공감")
                    .font(.custom("NanumSquareOTFBold", size: 10))
                    .foregroundColor(Color("MainThemeColor"))
            }
            .padding(EdgeInsets(top: 6.5, leading: 8.25, bottom: 6.5, trailing: 8.25))
            .cornerRadius(6)
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color("MainThemeColor"),lineWidth: 1))
        }
    }
    var commentList: some View {
        LazyVStack(spacing:0){
            ForEach(viewModel.commentsListPublisher) { comment in
                CommentCell(comment: comment, viewModel: viewModel, reportCompleteAlertIsShown: $reportCompleteAlertIsShown, alertTitle: $alertTitle, alertMessage: $alertMessage,onMenuPressed: {
                    showCommentId = comment.id
                    commentContent = comment.content
                    showCommentMine = comment.isMine
                    showCommentMenu = true
                })
                    
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
    var commentMenu: some View{
        VStack{
            VStack(spacing:0){
                Spacer()
                    .frame(height:12.4)
                Text("댓글 메뉴")
                    .font(.custom("Inter-Medium", size: 10))
                    .foregroundColor(Color("Grey5"))
                Spacer()
                    .frame(height:16.9)
                if(showCommentMine){
                    Divider()
                        .foregroundColor(Color("CommunityPostMenuColor"))
                    Spacer()
                        .frame(height:15)
                    Button(action:{     
                        showCommentEditView = true
                        showCommentMenu = false
                    },label: {Text("수정하기")
                            .frame(maxWidth:.infinity)
                            .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(Color("CommunityPostMenuTextColor"))}
                    )
                    Spacer()
                        .frame(height:15)
                    
                    Divider()
                        .foregroundColor(Color("CommunityPostMenuColor"))
                    Spacer()
                        .frame(height:15)
                    
                    Button(action:{ showCommentDeleteAlert = true
                        showCommentMenu = false
                    },label: {Text("삭제하기")
                            .frame(maxWidth:.infinity)
                            .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(Color("CommunityPostMenuTextColor"))})
                    Spacer()
                        .frame(height:15)
                    
                }
                else{
                    Divider()
                        .foregroundColor(Color("CommunityPostMenuColor"))
                    Spacer()
                        .frame(height:15)
                    
                    
                    Button(action:{
                        showCommentMenu = false
                        showAlert = true
                        
                    },label:{
                        Text("신고하기")
                            .frame(maxWidth:.infinity)
                            .font(.custom("Inter-Medium", size: 16))
                            .foregroundColor(Color("CommunityPostMenuTextColor"))
                    })
                    
                    
                    Spacer()
                        .frame(height:15)
                    
                }
                // color really change
            }
            .background(Color("DividerColor") ) // NO NAME
            .cornerRadius(10)
            Color.clear
                .frame(height: 8)
            VStack{
                Spacer()
                    .frame(height:15)
                
                Button(action:{
                    showCommentMenu = false
                },label: {Text("취소")
                        .frame(maxWidth:.infinity)
                        .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(Color("CommunityPostMenuTextColor"))})
                
                
                Spacer()
                    .frame(height:15)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
          
            
        }
      //  .frame(height: 298.83) // Adjust height as needed
        .padding(EdgeInsets(top: 0, leading: 15.5, bottom: 0, trailing: 16.5))
    }
    var postMenu: some View{
        VStack{
            VStack(spacing:0){
                Spacer()
                    .frame(height:12.4)
                Text("게시글 메뉴")
                    .font(.custom("Inter-Medium", size: 10))
                    .foregroundColor(Color("Grey5"))
                Spacer()
                    .frame(height:16.9)
                if(viewModel.postInfo.isMine){
                    Divider()
                        .foregroundColor(Color("CommunityPostMenuColor"))
                    Spacer()
                        .frame(height:15)
                    Button(action:{     isEditingPost = true
                        showPostMenu = false
                    },label: {Text("수정하기")
                            .frame(maxWidth:.infinity)
                            .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(Color("CommunityPostMenuTextColor"))}
                    )
                    Spacer()
                        .frame(height:15)
                    
                    Divider()
                        .foregroundColor(Color("CommunityPostMenuColor"))
                    Spacer()
                        .frame(height:15)
                    
                    Button(action:{ showPostMenu = false
                        showPostDeleteAlert = true
                    },label: {Text("삭제하기")
                            .frame(maxWidth:.infinity)
                            .font(.custom("Inter-Medium", size: 16))
                        .foregroundColor(Color("CommunityPostMenuTextColor"))})
                    Spacer()
                        .frame(height:15)
                    
                }
                else{
                    Divider()
                        .foregroundColor(Color("CommunityPostMenuColor"))
                    Spacer()
                        .frame(height:15)
                    
                    
                    Button(action:{
                        showPostMenu = false
                        showAlert = true
                        
                    },label:{
                        Text("신고하기")
                            .frame(maxWidth:.infinity)
                            .font(.custom("Inter-Medium", size: 16))
                            .foregroundColor(Color("CommunityPostMenuTextColor"))
                    })
                    
                    
                    Spacer()
                        .frame(height:15)
                    
                }
                // color really change
            }
            .background(Color("DividerColor") ) // NO NAME
            .cornerRadius(10)
            Color.clear
                .frame(height: 8)
            VStack{
                Spacer()
                    .frame(height:15)
                
                Button(action:{
                    showPostMenu =  false
                },label: {Text("취소")
                        .frame(maxWidth:.infinity)
                        .font(.custom("Inter-SemiBold", size: 16))
                    .foregroundColor(Color("CommunityPostMenuTextColor"))})
                
                
                Spacer()
                    .frame(height:15)
            }
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .cornerRadius(10)
            
            
            
            
            
        }
        //.frame(height: 298.83) // Adjust height as needed
        .padding(EdgeInsets(top: 0, leading: 15.5, bottom: 0, trailing: 16.5))
        
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
                .foregroundColor(Color("MainThemeColor"))
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
                Button(action:{showPostDeleteAlert = false},label:{Text("취소")
                        .font(.custom("Inter-Bold", size: 16))
                    .frame(maxWidth:.infinity)})
                .foregroundColor(Color("MainThemeColor"))
                .frame(maxWidth: .infinity,alignment: .center)
                Divider()
                Button(action:{
                    viewModel.deleteComment(id:showCommentId){completion in
                        viewModel.loadBasicInfos()
                        showCommentDeleteAlert = false
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
            VStack{
                ZStack{
                    Color("MainThemeColor")
                        .ignoresSafeArea(.all)
                    HStack{
                        backButton
                        Spacer()
                    }.padding(.zero)
                    HStack{
                        Text(viewModel.boardNamePublisher)
                            .foregroundColor(.white)
                            .frame(alignment: .center)
                            .font(.custom("Inter-Bold", size: 16))
                    }.padding(.zero)
                    
                }.frame(height:44)
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing:0) {
                        postHeader
                        VStack(alignment: .leading) {
                            
                            Text(viewModel.postInfo.title)
                                .font(.custom("NanumSquareOTFExtraBold", size: 16))
                            Spacer()
                                .frame(height:12)
                            Text(viewModel.postInfo.content)
                                .font(.custom("NanumSquareOTFRegular", size: 12))
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
                                        .font(.custom("Inter-Regular", size: 9))
                                        .foregroundColor(Color("MainThemeColor"))
                                }
                                
                                HStack(alignment: .center) {
                                    Image("Comment")
                                        .frame(width: 11.5, height: 11)
                                    Spacer()
                                        .frame(width: 4)
                                    Text(String(viewModel.postInfo.commentCount))
                                        .font(.custom("Inter-Regular", size: 9))
                                        .foregroundColor(Color.init("ReviewMediumColor"))
                                        .frame(height: 11, alignment: .center)
                                }
                                
                                Spacer()
                                
                                
                                
                            }
                            Spacer()
                                .frame(height:14)
                            likeButton
                            
                        }
                        .padding(EdgeInsets(top: 15, leading: 22, bottom: 12.5, trailing: 19))
                        
                        Divider()
                            .foregroundColor(Color("Low"))
                            .padding(.zero)
                        
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
                CommunityReplyBar(onCommentSubmit: { commentText,isAnonymous in
                    viewModel.submitComment(postId: viewModel.postInfo.id, content: commentText,isAnonymous: isAnonymous)
                })
                if(showPostMenu){
                    Color.black.opacity(0.4)
                        .ignoresSafeArea(.all)
                    
                    postMenu
                }
                if(showPostDeleteAlert){
                    Color.black.opacity(0.4)
                        .ignoresSafeArea(.all)
                    
                    ZStack(alignment: .center){
                        postDeleteAlert
                            .background(Color.white)
                            .cornerRadius(26)
                        
                    }.frame(maxWidth:.infinity,maxHeight: .infinity)
                        .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
                }
            if(showCommentDeleteAlert){
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                
                ZStack(alignment: .center){
                    commentDeleteAlert
                        .background(Color.white)
                        .cornerRadius(26)
                    
                }.frame(maxWidth:.infinity,maxHeight: .infinity)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
            }
            if(showCommentMenu){
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                
                commentMenu
            }
                
            }.customNavigationBar(title: viewModel.boardNamePublisher)
                .navigationBarItems(leading: backButton)
                .onAppear {
                 //   viewModel.loadBasicInfos()
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
                .fullScreenCover(isPresented: $isEditingPost){
                    CommunityPostPublishView(
                        needRefresh: self.$needRefresh, viewModel: CommunityPostPublishViewModel(
                            boardId: viewModel.postInfo.boardId,
                            communityRepository:DomainManager.shared.domain.communityRepository,
                            postInfo: viewModel.postInfo
                        )
                    )
                }
                .fullScreenCover(isPresented: $showImages){
                    ImageView(viewModel: viewModel, imageIndex: imageIndex)
                    
                }
                .fullScreenCover(isPresented: $showAlert){
                    AlertView(RenewalSettingsViewModel(), viewModel,commentId: showPostMenu ? nil : showCommentId)
                }
                .fullScreenCover(isPresented: $showCommentEditView) {
                    EditCommentView(isPresented: $showCommentEditView, editedContent: commentContent, onSave: { newContent in
                        viewModel.editComment(commentId: showCommentId, content: newContent)
                        showCommentEditView = false
                    }, onCancel: {
                        showCommentEditView = false
                    })
                }
                .onAppear{
                    appState.showTabbar = false
                    print("onAppear")
                }
                .onDisappear{
                    appState.showTabbar = true
                }
                .onChange(of: isEditingPost, perform: {
                    isEditingPost in
                    if(!isEditingPost){
                            self.presentationMode.wrappedValue.dismiss()

                        

                                  }
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
 CommunityPostView(viewModel: StubCommunityPostViewModel(), boardName: StubCommunityViewModel().getSelectedBoardName(), needPostViewRefresh:)
 }
 }*/

class StubCommunityPostViewModel: CommunityPostViewModelType {
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
