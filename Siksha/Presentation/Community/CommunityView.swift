//
//  ComunityView.swift
//  Siksha
//
//  Created by 김령교 on 7/29/23.
//

import SwiftUI

struct CommunityView<ViewModel>: View where ViewModel: CommunityViewModelType {
    @State private var tag: Int? = nil
    @State private var needRefresh = false
    private let topPosts: [PostInfo] = (1..<5).map {
        return PostInfo(title: "name\($0)",
                     content: "content\($0)",
                     isLiked: $0 % 2 == 0,
                     likeCount: $0,
                     commentCount: $0,
                     imageURLs: nil,
                     isAnonymous: false,
                     isMine: false)
    }
    
    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                Spacer().frame(height: 18)
                BoardList(viewModel: viewModel)
                
                if !viewModel.trendingPostsListPublisher.isEmpty {
                    Spacer().frame(height: 13)
                    TopPosts(infos: viewModel.trendingPostsListPublisher, needRefresh: $needRefresh)
                }
                Spacer().frame(height: 18)
                
                if viewModel.loadInitialPostsStatus == .loading && (viewModel.postsListPublisher.isEmpty || viewModel.isChangingBoard) {
                    loadingView
                } else {
                    ScrollView(showsIndicators: false) {
                        postList
                    }
                    .refreshable {
                        await viewModel.asyncRefresh()
                    }
                }
                
                Spacer(minLength: 0)
            }
            .customNavigationBar(title: "icon")
            
            Button {
                tag = 1
            } label: {
                NavigationLink(
                    destination: CommunityPostPublishView(
                        needRefresh: $needRefresh,
                        viewModel: CommunityPostPublishViewModel(
                            boardId:selectedBoardId ?? 0,
                            communityRepository: AppContainer.shared.domain.communityRepository
                        )
                    ),
                    tag: 1,
                    selection: self.$tag
                ){
                    Image("Pencil")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(.white)
                        .frame(width: 50, height: 50)
                        .background(Color.orange500)
                        .clipShape(Circle())
                }
            }
            .disabled(selectedBoardId == nil)
            .padding(.trailing, 29)
            .padding(.bottom, 24)
        }
        .background(Color.backgroundPrimary)
        .errorAlert(error: $viewModel.error)
        .onAppear {
            self.viewModel.loadBasicInfos()
        }
        .onChange(of: needRefresh, perform: { refresh in
            if refresh{
                self.viewModel.loadSelectedBoardPosts()
                self.viewModel.loadTrendingPosts()
                needRefresh = false
            }
        })
    }
    
    var loadingView: some View {
        VStack {
            Spacer()
            ActivityIndicator(isAnimating: .constant(true), style: .large)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    var divider: some View {
        Divider()
            .foregroundColor(.gray100)
            .frame(height:1)
            .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 0, trailing: 7.5))
    }
    
    var postList: some View {
        LazyVStack(spacing: 0) {
            divider
            ForEach(self.viewModel.postsListPublisher) { postInfo in
                if postInfo.isAvailable {
                    CommunityPostPreView(
                        info: postInfo,
                        boardName: viewModel.getSelectedBoardName(),
                        needRefresh: $needRefresh
                    )
                    divider
                }
            }
            
            if self.viewModel.hasNextPublisher == true {
                HStack {
                  Spacer()
                  ProgressView()
                      .onAppear {
                          self.viewModel.loadMorePosts()
                      }
                  Spacer()
                }
                .frame(height: 40)
            }
        }
    }
    
    var selectedBoardId: Int? {
        let boards = viewModel.boardsListPublisher.filter {
            board in board.isSelected
        }
        return boards.isEmpty ? nil : boards[0].id
    }
}

struct CommunityPostPreView: View {
    let info: PostInfo
    let boardName: String
    let needRefresh: Binding<Bool>
    
    var body: some View {
        NavigationLink {
            CommunityPostView(
                viewModel: CommunityPostViewModel(
                    communityRepository: AppContainer.shared.domain.communityRepository,
                    postId: info.id
                ),
                needPostViewRefresh: needRefresh
            )
        } label: {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(info.title)
                        .customFont(font: .text13(weight: .ExtraBold))
                        .foregroundColor(.blackColor)
                        .lineLimit(1)
                    
                    Text(info.content)
                        .customFont(font: .text13(weight: .Regular))
                        .foregroundColor(.gray900)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 4) {
                        Image("PostLike-default")
                            .resizable()
                            .frame(width: 11.5, height: 11)
                            .scaledToFit()
                        Text(String(info.likeCount))
                            .customFont(font: .text11(weight: .Bold))
                            .foregroundColor(.orange500)
                            .padding(.trailing, 7)
                        Image("Comment")
                            .resizable()
                            .frame(width: 12, height: 11)
                            .scaledToFit()
                        Text(String(info.commentCount))
                            .customFont(font: .text11(weight: .Bold))
                            .foregroundColor(.gray700)
                    }
                }
                
                if let firstImageURL = info.imageURLs?.first,
                    let url = URL(string: firstImageURL) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 61, height: 61)
                    .clipped()
                }
            }
            .padding(EdgeInsets(top: 15, leading: 20, bottom: 13, trailing: 20))
        }
    }
}

struct ComunityView_Previews: PreviewProvider {
    static var previews: some View {
        CommunityView(viewModel: StubCommunityViewModel())
    }
}

class StubCommunityViewModel: CommunityViewModelType {
    @Published var error: AppError?
    func asyncRefresh() async {
        
    }
    
    func loadTrendingPosts() {
        
    }
    
    var trendingPostsListPublisher: [PostInfo] = [
        .init(
            title: "제목",
            content: "내용",
            isLiked: true,
            likeCount: 12,
            commentCount: 2,
            imageURLs: nil,
            isAnonymous: true,
            isMine: false
        ),
        .init(
            title: "제목22222",
            content: "내용",
            isLiked: true,
            likeCount: 12,
            commentCount: 2,
            imageURLs: nil,
            isAnonymous: true,
            isMine: false
        )
    ]
    
    var hasNextPublisher: Bool {
        return false
    }
    
    var postsListPublisher: [PostInfo] = (1..<5).map {
        return PostInfo(title: "name\($0)",
                     content: "content\($0)",
                     isLiked: $0 % 2 == 0,
                     likeCount: $0,
                     commentCount: $0,
                     imageURLs: nil,
                     isAnonymous: false,
                     isMine: false)
    }
    
    
    var boardsListPublisher: [BoardInfo] = [
        BoardInfo(id: 1, type: 1, name: "name1", isSelected: true),
        BoardInfo(id: 2, type: 1, name: "name2", isSelected: false),
        BoardInfo(id: 3, type: 1, name: "name3", isSelected: false)
    ]
    
    var loadInitialPostsStatus: InitialPostsStatus = .idle
    var isChangingBoard: Bool = false
    
    func loadBasicInfos() { }
    func loadMorePosts() { }
    func loadSelectedBoardPosts() { }
    func selectBoard(id: Int) { }
    func getSelectedBoardName() -> String {
        return "board1"
    }
}
