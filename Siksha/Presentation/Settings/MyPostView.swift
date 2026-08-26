//
//  MyPostView.swift
//  Siksha
//
//  Created by 김령교 on 5/12/24.
//

import SwiftUI

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
        BackButton {
            self.presentationMode.wrappedValue.dismiss()
        }
    }

    var body: some View {
        Group {
            if viewModel.isInitialLoading {
                VStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if self.viewModel.postsListPublisher.count == 0 {
                VStack(alignment: .center) {
                    Spacer()
                    Text("내가 쓴 글이 없어요")
                        .customFont(font: .text15(weight: .Bold))
                        .foregroundStyle(Color.gray600)
                    Spacer()
                }
                .errorAlert(error: $viewModel.error)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    postList
                }
            }
        }
        .background(Color.backgroundPrimary)
        .customNavigationBar(title: "내가 쓴 글")
        .navigationBarItems(leading: backButton)
        .onAppear {
            viewModel.loadPosts()
        }
        .onChange(of: needRefresh) { _, refresh in
            if refresh {
                viewModel.loadPosts()
                needRefresh = false
            }
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
    var isInitialLoading: Bool = false

    var hasNextPublisher: Bool {
        return false
    }

    var postsListPublisher: [PostInfo] = (1..<5).map {
        return PostInfo(
            title: "name\($0)",
            content: "content\($0)",
            isLiked: $0 % 2 == 0,
            likeCount: $0,
            commentCount: $0,
            imageURLs: [""],
            isAnonymous: false,
            isMine: false)
    }

    func loadMorePosts() {}
    func loadPosts() {}
}
