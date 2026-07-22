//
//  CommunityPostView.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/08/06.
//

import Kingfisher
import SwiftUI

struct CommunityPostView<ViewModel>: View where ViewModel: CommunityPostViewModelType {
    private enum chosenType: Identifiable {
        case post(post: PostInfo)
        case comment(comment: CommentInfo)

        var id: Int {
            switch self {
            case .post(let post):
                return post.id
            case .comment(let comment):
                return -comment.id
            }
        }
    }

    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var viewModel: ViewModel

    @State private var anonymousIsToggled = false
    @State private var commentContent: String = ""
    @State private var isEditingPost = false
    @State private var needRefresh = false
    @State private var imageIndex = 0
    @State private var showImages = false
    @State private var showAlert: chosenType? = nil
    @State private var showPostMenu = false
    @State private var showPostDeleteAlert = false
    @State private var editComment: CommentInfo? = nil
    @State private var deleteCommentId = 0
    @State private var showActionSheet: chosenType? = nil
    @Binding var needPostViewRefresh: Bool

    var backButton: some View {
        Button(action: {
            needPostViewRefresh = true
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .scaledToFit()
                .frame(width: 24, height: 24)
                .foregroundColor(Color.iconWhiteIcon)
        }
        .contentShape(Rectangle())
    }

    var imageSection: some View {
        Group {
            if let imageURLs = viewModel.postInfo.imageURLs {
                ZStack(alignment: .topTrailing) {
                    TabView(selection: $imageIndex) {
                        ForEach(Array(imageURLs.enumerated()), id: \.0) { index, imageURLString in
                            AsyncImage(url: URL(string: imageURLString)) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.white
                            }
                            .tag(index)
                            .frame(width: UIScreen.main.bounds.width - 39, height: UIScreen.main.bounds.width - 39)
                        }
                    }
                    .simultaneousGesture(
                        TapGesture().onEnded { showImages = true }
                    )
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                    .frame(width: UIScreen.main.bounds.width - 39, height: UIScreen.main.bounds.width - 39)

                    Text("\(imageIndex + 1)/\(imageURLs.count)")
                        .customFont(font: .text11(weight: .Bold))
                        .foregroundStyle(Color.textButton)
                        .padding(.vertical, 1)
                        .padding(.horizontal, 6)
                        .background(Color.iconCloseBg)
                        .cornerRadius(10)
                        .padding(11)
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

    var postHeader: some View {
        HStack(spacing: 8) {
            if let profileUrl = viewModel.postInfo.profileUrl {
                KFImage(URL(string: profileUrl))
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            } else {
                Image(.Icons.Common.profileImagePlaceholder)
                    .resizable()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 0) {
                Text(viewModel.postInfo.isAnonymous ? "익명" : "\(viewModel.postInfo.nickname ?? "")")
                    .customFont(font: .text12(weight: .Bold))
                    .foregroundColor(.blackColor)
                Text(relativeDate)
                    .customFont(font: .text12(weight: .Regular))
                    .foregroundColor(.gray600)
            }
            Spacer()
            Image("etc")
                .resizable()
                .scaledToFit()
                .frame(width: 33, height: 33)
                .onTapGesture {
                    showActionSheet = .post(post: viewModel.postInfo)
                }
        }
    }

    var likeButton: some View {
        Button(action: {
            viewModel.togglePostLike()
        }) {
            Image(viewModel.postInfo.isLiked ? "LikeButton-liked" : "LikeButton-default")
        }
    }

    var commentList: some View {
        LazyVStack(spacing: 0) {
            ForEach(viewModel.commentsListPublisher) { comment in
                CommentCell(
                    comment: comment, viewModel: viewModel,
                    onMenuPressed: {
                        showActionSheet = .comment(comment: comment)
                        commentContent = comment.content
                    })

                divider
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

    var postDeleteAlert: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 18.34)
            Text("게시글 삭제")
                .customFont(font: .text16(weight: .ExtraBold))
                .foregroundStyle(Color.blackColor)
            Spacer()
                .frame(height: 7.23)
            Text("게시글을 정말 삭제하시겠습니까?")
                .customFont(font: .text13(weight: .Regular))
            Spacer()
                .frame(height: 13.84)
            Divider()
                .foregroundStyle(Color.borderPrimary)
            HStack(spacing: 0) {
                Button(
                    action: { showPostDeleteAlert = false },
                    label: {
                        Text("취소")
                            .customFont(font: .text16(weight: .ExtraBold))
                            .frame(maxWidth: .infinity)
                    }
                )
                .foregroundColor(.orange500)
                .frame(maxWidth: .infinity, alignment: .center)
                Divider()
                    .foregroundStyle(Color.borderPrimary)
                Button(
                    action: {
                        viewModel.deletePost { success in
                            if success {
                                self.needPostViewRefresh = true
                                self.presentationMode.wrappedValue.dismiss()
                            } else {
                            }
                        }
                    },
                    label: {
                        Text("삭제").customFont(font: .text16(weight: .Regular))
                            .frame(maxWidth: .infinity).foregroundStyle(Color.gray700)
                    }
                )
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .background(Color.backgroundSecondary)
        .frame(width: 315, height: 130.3, alignment: .center)
    }

    var commentDeleteAlert: some View {
        VStack(spacing: 0) {
            Spacer()
                .frame(height: 18.34)
            Text("댓글 삭제")
                .customFont(font: .text16(weight: .ExtraBold))
                .foregroundStyle(Color.blackColor)
            Spacer()
                .frame(height: 7.23)
            Text("댓글을 정말 삭제하시겠습니까?")
                .customFont(font: .text13(weight: .Regular))
            Spacer()
                .frame(height: 13.84)
            Divider()
                .foregroundStyle(Color.borderPrimary)
            HStack(spacing: 0) {
                Button(
                    action: {
                        deleteCommentId = -1
                    },
                    label: {
                        Text("취소")
                            .customFont(font: .text16(weight: .ExtraBold))
                            .frame(maxWidth: .infinity)
                    }
                ).foregroundColor(.orange500).foregroundColor(Color("Orange500"))
                    .frame(maxWidth: .infinity, alignment: .center)
                Divider()
                    .foregroundStyle(Color.borderPrimary)
                Button(
                    action: {
                        viewModel.deleteComment(id: deleteCommentId) { _ in
                            viewModel.loadBasicInfos()
                            deleteCommentId = -1
                        }
                    },
                    label: {
                        Text("삭제").customFont(font: .text16(weight: .Regular))
                            .frame(maxWidth: .infinity).foregroundStyle(Color.gray700)
                    }
                )
                .frame(maxWidth: .infinity, alignment: .center)
            }
        }
        .background(Color.backgroundSecondary)
        .frame(width: 315, height: 130.3, alignment: .center)
    }

    var divider: some View {
        Divider()
            .foregroundColor(.gray100)
            .padding(.horizontal, 7.5)
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 0) {
                        postHeader
                            .padding(.bottom, 18)
                            .padding(.horizontal, 19.5)
                            .padding(.top, 16.5)

                        VStack(alignment: .leading, spacing: 0) {
                            Text(viewModel.postInfo.title)
                                .customFont(font: .text16(weight: .ExtraBold))
                                .foregroundStyle(Color.blackColor)
                            Spacer()
                                .frame(height: 12)
                            Text(viewModel.postInfo.content)
                                .customFont(font: .text13(weight: .Regular))
                                .foregroundStyle(Color.gray900)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            if viewModel.postInfo.imageURLs?.isEmpty == false {
                                Spacer()
                                    .frame(height: 18)
                            }

                            imageSection

                            Spacer()
                                .frame(height: 15)

                            HStack(spacing: 4) {
                                Image("like")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 11.5, height: 11)
                                    .foregroundStyle(Color.orange500)

                                Text(String(viewModel.postInfo.likeCount))
                                    .customFont(font: .text11(weight: .Bold))
                                    .foregroundColor(.orange500)
                                Image("Comment")
                                    .resizable()
                                    .frame(width: 12, height: 11)
                                    .scaledToFit()
                                Text(String(viewModel.postInfo.commentCount))
                                    .customFont(font: .text11(weight: .Bold))
                                    .foregroundColor(.gray700)
                            }

                            Spacer()
                                .frame(height: 15)
                            likeButton
                        }
                        .padding(.horizontal, 19.5)
                        .padding(.bottom, 12)

                        divider
                        commentList

                        Spacer()
                    }
                    .edgesIgnoringSafeArea(.top)
                }
                .onTapGesture {
                    self.endTextEditing()
                }

                ZStack {
                    Rectangle()
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .foregroundColor(.backgroundPrimary)

                    CommunityReplyBar(onCommentSubmit: { commentText, isAnonymous in
                        viewModel.submitComment(
                            postId: viewModel.postInfo.id, content: commentText, isAnonymous: isAnonymous)
                    })
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .background(Color.backgroundPrimary)

            if showPostDeleteAlert {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        showPostDeleteAlert = false
                    }
                ZStack(alignment: .center) {
                    postDeleteAlert
                        .background(Color.white)
                        .cornerRadius(26)

                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
            }
            if deleteCommentId > 0 {
                Color.black.opacity(0.4)
                    .ignoresSafeArea(.all)
                    .onTapGesture {
                        deleteCommentId = -1
                    }
                ZStack(alignment: .center) {
                    commentDeleteAlert
                        .background(Color.white)
                        .cornerRadius(26)

                }.frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(EdgeInsets(top: 0, leading: 30, bottom: 0, trailing: 30))
            }
        }
        .customNavigationBar(title: viewModel.boardNamePublisher)
        .navigationBarItems(leading: backButton)
        .refreshable {
            await viewModel.asyncRefresh()
        }
        .actionSheet(item: $showActionSheet) { item in
            switch item {
            case .post(let post):
                let editButton = ActionSheet.Button.default(
                    Text("수정하기"),
                    action: {
                        isEditingPost = true
                        showPostMenu = false
                    })
                let deleteButton = ActionSheet.Button.default(
                    Text("삭제하기"),
                    action: {
                        showPostMenu = false
                        showPostDeleteAlert = true
                    })
                let reportButton = ActionSheet.Button.default(
                    Text("신고하기"),
                    action: {
                        showPostMenu = false
                        showAlert = item
                    })
                let copyURLButton = ActionSheet.Button.default(
                    Text("URL 복사하기"),
                    action: {
                        showPostMenu = false
                        UIPasteboard.general.string = ""
                    })
                let blockButton = ActionSheet.Button.default(
                    Text("차단하기"),
                    action: {
                        viewModel.blockPostAuthor(postInfo: post)
                        needPostViewRefresh = true
                        presentationMode.wrappedValue.dismiss()
                    })
                if viewModel.postInfo.isMine {
                    return ActionSheet(
                        title: Text("게시글 메뉴"),
                        buttons: [
                            editButton, deleteButton, reportButton, copyURLButton,
                            .cancel(Text("취소")),
                        ])
                } else {
                    return ActionSheet(
                        title: Text("게시글 메뉴"),
                        buttons: [
                            reportButton, copyURLButton, blockButton,
                            .cancel(Text("취소")),
                        ])
                }
            case .comment(let comment):
                let editButton = ActionSheet.Button.default(
                    Text("수정하기"),
                    action: {
                        editComment = comment
                        showActionSheet = nil
                    })
                let deleteButton = ActionSheet.Button.default(
                    Text("삭제하기"),
                    action: {
                        deleteCommentId = comment.id
                        showActionSheet = nil
                    })
                let reportButton = ActionSheet.Button.default(
                    Text("신고하기"),
                    action: {
                        showAlert = item
                    })
                let blockButton = ActionSheet.Button.default(
                    Text("차단하기"),
                    action: {
                        viewModel.blockCommentAuthor(commentInfo: comment)
                        showActionSheet = nil
                    })
                if comment.isMine {
                    return ActionSheet(
                        title: Text("댓글 메뉴"),
                        buttons: [
                            editButton, deleteButton,
                            .cancel(Text("취소")),
                        ])
                } else {
                    return ActionSheet(
                        title: Text("댓글 메뉴"),
                        buttons: [
                            reportButton, blockButton,
                            .cancel(Text("취소")),
                        ])
                }
            }
        }
        .fullScreenCover(isPresented: $isEditingPost) {
            CommunityPostPublishView(
                needRefresh: self.$needRefresh, needPostViewRefresh: self.$needPostViewRefresh,
                viewModel: CommunityPostPublishViewModel(
                    boardId: viewModel.postInfo.boardId,
                    communityRepository: AppContainer.shared.domain.communityRepository,
                    orderedImageDataLoader: AppContainer.shared.orderedImageDataLoader,
                    uploadImagePreparer: AppContainer.shared.uploadImagePreparer,
                    postInfo: viewModel.postInfo
                )
            )
        }
        .fullScreenCover(isPresented: $showImages) {
            ImageView(viewModel: viewModel, imageIndex: imageIndex)
        }
        .fullScreenCover(item: $showAlert) { item in
            switch item {
            case .post:
                AlertView(
                    RenewalSettingsViewModel(
                        manageRestaurantsWithoutMenuVisibilityUseCase: AppContainer.shared.useCases
                            .manageRestaurantsWithoutMenuVisibilityUseCase,
                        fetchCurrentUserUseCase: AppContainer.shared.useCases.fetchCurrentUserUseCase,
                        submitVOCUseCase: AppContainer.shared.useCases.submitVOCUseCase,
                        fetchAppStoreVersionUseCase: AppContainer.shared.useCases.fetchAppStoreVersionUseCase
                    ),
                    viewModel,
                    commentId: nil
                )
            case .comment(let comment):
                AlertView(
                    RenewalSettingsViewModel(
                        manageRestaurantsWithoutMenuVisibilityUseCase: AppContainer.shared.useCases
                            .manageRestaurantsWithoutMenuVisibilityUseCase,
                        fetchCurrentUserUseCase: AppContainer.shared.useCases.fetchCurrentUserUseCase,
                        submitVOCUseCase: AppContainer.shared.useCases.submitVOCUseCase,
                        fetchAppStoreVersionUseCase: AppContainer.shared.useCases.fetchAppStoreVersionUseCase
                    ),
                    viewModel,
                    commentId: comment.id
                )
            }
        }
        .fullScreenCover(item: $editComment) { comment in
            EditCommentView(
                editedContent: comment.content,
                onSave: { newContent in
                    viewModel.editComment(commentId: comment.id, content: newContent)
                    editComment = nil
                },
                onCancel: {
                    editComment = nil
                })
        }
    }
}

extension View {
    func endTextEditing() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil)
    }
}

#Preview {
    CommunityPostView(viewModel: StubCommunityPostViewModel(), needPostViewRefresh: .constant(false))
}

class StubCommunityPostViewModel: CommunityPostViewModelType {
    var error: AppError?

    func asyncRefresh() async {}

    func deleteComment(id: Int, completion: @escaping (Bool) -> Void) {}

    var boardNamePublisher: String

    @Published var reportAlert: Bool = false
    @Published var reportErrorAlert: Bool = false

    var reportAlertPublished: Published<Bool> { _reportAlert }
    var reportAlertPublisher: Published<Bool>.Publisher { $reportAlert }

    var reportErrorAlertPublished: Published<Bool> { _reportErrorAlert }
    var reportErrorAlertPublisher: Published<Bool>.Publisher { $reportErrorAlert }

    @Published var commentsListPublisher: [CommentInfo]
    @Published var hasNextPublisher: Bool

    @MainActor
    init() {
        self.commentsListPublisher = [
            CommentInfo(content: "test1", likeCnt: 1, isLiked: true),
            CommentInfo(content: "test2", likeCnt: 0, isLiked: false),
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
            imageURLs: [
                "https://images.unsplash.com/photo-1755148500082-8f39dea5dc0a?q=80&w=1964&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
            ],
            isAnonymous: true,
            isMine: true
        )
    }

    func reportPost(reason: String, completion: @escaping (Bool, String?) -> Void) {
        reportAlert = true
        completion(true, nil)
    }

    func reportComment(commentId: Int, reason: String, completion: @escaping (Bool, String?) -> Void) {
        reportAlert = true
        completion(true, nil)
    }

    func editPost() {}

    func deletePost(completion: @escaping (Bool) -> Void) {
        completion(true)
    }

    func togglePostLike() {}

    func loadBasicInfos() {}

    func loadMoreComments() {}

    func submitComment(postId: Int, content: String, isAnonymous: Bool) {}

    func editComment(commentId id: Int, content: String) {}

    func deleteComment(id: Int) {}

    func toggleCommentLike(id: Int) {}

    func blockPostAuthor(postInfo: PostInfo) {}
    func blockCommentAuthor(commentInfo: CommentInfo) {}
}
