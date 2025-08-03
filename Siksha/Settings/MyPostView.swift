//
//  MyPostView.swift
//  Siksha
//
//  Created by 김령교 on 5/12/24.
//

import SwiftUI

struct MyPostPreView: View {
    private let contentColor = Color("Color/Foundation/Orange/900")
    private let likeColor = Color("Color/Foundation/Orange/500")
    private let replyColor = Color("Color/Foundation/Gray/700")
    private let defaultImageColor = Color("Color/Foundation/Gray/199")
    
    let info: PostInfo
    let boardName: String
    let needRefresh:Binding<Bool>
    
    var body: some View {
        NavigationLink(destination: CommunityPostView(viewModel: CommunityPostViewModel(communityRepository: DomainManager.shared.domain.communityRepository, postId: info.id), needPostViewRefresh:needRefresh)) {
            HStack {
                VStack(alignment: .leading) {
                    Text(info.title)
                        .font(.custom("Inter-Bold", size: 15))
                    Spacer()
                        .frame(width: 10)
                    Text(info.content)
                        .font(.custom("Inter-ExtraLight", size: 12))
                        .foregroundColor(contentColor)
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
                                .font(.custom("Inter-Regular", size: 9))
                            
                                .foregroundColor(likeColor)
                        }
                        HStack(alignment: .center) {
                            Image("Comment")
                                .frame(width: 11.5, height: 11)
                            Spacer()
                                .frame(width: 4)
                            Text(String(info.commentCount))
                                .font(.custom("Inter-Regular", size: 9))
                                .foregroundColor(Color.init("Color/Foundation/Gray/700"))
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
}

struct MyPostView<ViewModel>: View where ViewModel: MyPostViewModelType {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State var tag: Int? = nil
    @State var needRefresh = false
    let dividerColor = Color("Color/Foundation/Gray/100")
    
    @ObservedObject private var viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
        
    }
    
    var backButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image("NavigationBack")
                .resizable()
                .frame(width: 7, height: 15)
        }
    }

    var body: some View {
        if self.viewModel.postsListPublisher.count == 0 {
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
                Spacer()
                Text("내가 쓴 글이 없어요")
                    .font(.custom("NanumSquareOTF", size: 15))
                    .foregroundColor(Color(white: 166/255))
                Spacer()
            }
            .errorAlert(error: $viewModel.error)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .customNavigationBar(title: "내가 쓴 글")
                .navigationBarItems(leading: backButton)
           
            .onChange(of: needRefresh, perform: { refresh in
                if refresh{
                    self.viewModel.loadPosts()
                    needRefresh = false
                }
            })
        } else {
            ScrollView{
                divider
                postList
            }
            .customNavigationBar(title: "내가 쓴 글")
                .navigationBarItems(leading: backButton)
                .onChange(of: needRefresh, perform: { refresh in
                    if refresh{
                        self.viewModel.loadPosts()
                        needRefresh = false
                    }
                })
        }
    }
    
    var divider: some View {
        Divider()
            .foregroundColor(dividerColor)
            .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
    }
    
    var postList: some View {
        LazyVStack(spacing: 0) {
            ForEach(self.viewModel.postsListPublisher) { postInfo in
                CommunityPostPreView(info: postInfo, boardName: "MyPost", needRefresh: $needRefresh) // TODO
                divider
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
}

struct MyPostView_Previews: PreviewProvider {
    static var previews: some View {
        MyPostView(viewModel: StubMyPostViewModel())
    }
}

class StubMyPostViewModel: MyPostViewModelType {
    var error: AppError?
    
    var hasNextPublisher: Bool {
        return false
    }
    
    var postsListPublisher: [PostInfo] = (1..<5).map {
        return PostInfo(title: "name\($0)",
                     content: "content\($0)",
                     isLiked: $0 % 2 == 0,
                     likeCount: $0,
                     commentCount: $0,
                     imageURLs: [""],
                     isAnonymous: false,
                     isMine: false)
    }
    
    func loadMorePosts() { }
    func loadPosts() { }
}
