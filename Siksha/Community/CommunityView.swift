//
//  ComunityView.swift
//  Siksha
//
//  Created by 김령교 on 7/29/23.
//

import SwiftUI

struct CommunityView<ViewModel>: View where ViewModel: CommunityViewModelType {
    @State var tag: Int? = nil
    @State var needRefresh = false
    let dividerColor = Color("Color/Foundation/Gray/100")
    
    let topPosts: [PostInfo] = (1..<5).map {
        return PostInfo(title: "name\($0)",
                     content: "content\($0)",
                     isLiked: $0 % 2 == 0,
                     likeCount: $0,
                     commentCount: $0,
                     imageURLs: nil,
                     isAnonymous: false,
                     isMine: false)
    }
    
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
    }

    var body: some View {
        
            ZStack(alignment: .bottomTrailing) {
                VStack(spacing:0){
                    BoardSelect(viewModel: viewModel)
                    if !viewModel.trendingPostsListPublisher.isEmpty {
                        Divider()
                            .foregroundColor(dividerColor)
                            .frame(height:1)
                            .padding(.zero)
                        TopPosts(infos: viewModel.trendingPostsListPublisher, needRefresh: $needRefresh).padding(EdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20))
                    }
                    if viewModel.loadInitialPostsStatus == .loading && (self.viewModel.postsListPublisher.isEmpty || self.viewModel.isChangingBoard) {
                        VStack {
                            Spacer()
                            ActivityIndicator(isAnimating: .constant(true), style: .large)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity)
                    } else {
                        ScrollView{
                            divider
                            postList
                        }
                        .refreshable {
                            await viewModel.asyncRefresh()
                        }
                    }
                }
                .customNavigationBar(title: "icon")
                
                Button {
                    self.tag = 1
                } label: {
                    Image("CircleWriteButton")
                        .frame(width:50, height:50)
                        .background(Color.init("Color/Foundation/Orange/500"))
                        .clipShape(Circle())
                }
                .offset(x: -30, y: -22)
                .disabled(selectedBoardId == nil
                )
                NavigationLink(destination: CommunityPostPublishView( needRefresh: $needRefresh, viewModel: CommunityPostPublishViewModel(boardId:selectedBoardId ?? 0,communityRepository: DomainManager.shared.domain.communityRepository)),
                               tag: 1,
                               selection: self.$tag){
                    EmptyView()
                }
                               .disabled(selectedBoardId == nil
                               )

            
            
        }
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
    
    var divider: some View {
        Divider()
            .foregroundColor(dividerColor)
            .frame(height:1)
            .padding(EdgeInsets(top: 0, leading: 7.5, bottom: 0, trailing: 7.5))
    }
    
    var postList: some View {
        LazyVStack(spacing: 0) {
            ForEach(self.viewModel.postsListPublisher) { postInfo in
                if postInfo.isAvailable {
                 
                        CommunityPostPreView(info: postInfo, boardName: viewModel.getSelectedBoardName(), needRefresh: $needRefresh)
                         
                    
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
    
    var writeButton: some View {
        Image("writeButton")
    }
    var selectedBoardId:Int?{
        get{
         
                let boards = viewModel.boardsListPublisher.filter{board in board.isSelected}
            return boards.isEmpty ? nil : boards[0].id
            
           
            
            }
    }
}

struct CommunityPostPreView: View {
    private let contentColor = Color("Color/Foundation/Gray/900")
    private let likeColor = Color("Color/Foundation/Orange/500")
    private let replyColor = Color("Color/Foundation/Gray/700")
    private let defaultImageColor = Color("Color/Foundation/Gray/100")
    
    let info: PostInfo
    let boardName: String
    let needRefresh:Binding<Bool>
    var body: some View {
        NavigationLink(destination: CommunityPostView(viewModel: CommunityPostViewModel(communityRepository: DomainManager.shared.domain.communityRepository, postId: info.id), needPostViewRefresh:needRefresh)) {
            
            HStack {
                VStack(alignment: .leading) {
                    Text(info.title)
                        .font(.custom("NanumSquareOTFEB", size: 15))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    Spacer()
                        .frame(width: 10)
                    Text(info.content)
                        .font(.custom("NanumSquareOTFR", size: 12))
                        .foregroundColor(contentColor)
                        .lineLimit(1)
                    Spacer()
                        .frame(width: 10)
                    HStack {
                        HStack(alignment: .center) {
                            Image(info.isLiked ? "PostLike-liked" : "PostLike-default")
                                .frame(width: 11.5, height: 10)
                                .padding(.init(top: 0, leading: 0, bottom: 1.56, trailing: 0))
                            Spacer()
                                .frame(width: 4)
                            Text(String(info.likeCount))
                                .font(.custom("NanumSquareOTFRegular", size: 10))
                            
                                .foregroundColor(likeColor)
                        }
                        HStack(alignment: .center) {
                            Image("Comment")
                                .frame(width: 11.5, height: 11)
                            Spacer()
                                .frame(width: 4)
                            Text(String(info.commentCount))
                                .font(.custom("NanumSquareOTFRegular", size: 10))
                                .foregroundColor(Color.init("Color/Foundation/Gray/700"))
                                .frame(height: 11, alignment: .center)
                            
                        }
                    }
                }
                Spacer()
                
                if let firstImageURL = info.imageURLs?.first, let url = URL(string: firstImageURL) {
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
            .padding(EdgeInsets(top: 15, leading: 20, bottom: 14, trailing: 20))
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
    
    var trendingPostsListPublisher: [PostInfo] = []
    
    var hasNextPublisher: Bool {
        return true
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
