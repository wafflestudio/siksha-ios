//
//  MyPostViewModel.swift
//  Siksha
//
//  Created by 김령교 on 5/17/24.
//

import Foundation
import Combine

protocol MyPostViewModelType: ObservableObject {
    var postsListPublisher: [PostInfo] { get }
    var hasNextPublisher: Bool { get }
    var error: AppError? { get set }

    func loadMorePosts()
    func loadPosts()
}

final class MyPostViewModel: MyPostViewModelType {
    struct Constants {
        static let initialPage = 1
        static let pageCount = 20
    }
    
    @Published var error: AppError?
    
    private let communityRepository: CommunityRepositoryProtocol
    
    @Published private var currPostList: [Post] = []
    private var currentPage: Int = 0
    
    @Published private var hasNext: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
        loadPosts()
    }
}

extension MyPostViewModel {
    
    var postsListPublisher: [PostInfo] {
        return self.currPostList
            .map { PostInfo(post: $0 )}
    }
    
    var hasNextPublisher: Bool {
        return self.hasNext
    }
}

extension MyPostViewModel {
    private func loadInitialPosts() {
        self.communityRepository
            .loadMyPostsPage(page: Constants.initialPage, perPage: Constants.pageCount)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: { [weak self] postsPage in
                self?.currPostList = postsPage.posts
                self?.currentPage = 1
                self?.hasNext = postsPage.hasNext
            })
            .store(in: &cancellables)
    }
    
    func loadMorePosts() {
        guard self.hasNext == true else {
            return
        }
        
        self.communityRepository
            .loadMyPostsPage(page: self.currentPage + 1, perPage: Constants.pageCount)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.error = ErrorHelper.categorize(error)
                }
            }, receiveValue: { [weak self] postsPage in
                self?.currPostList.append(contentsOf: postsPage.posts)
                self?.currentPage += 1
                self?.hasNext = postsPage.hasNext
            })
            .store(in: &cancellables)
    }
    func loadPosts() {
        loadInitialPosts()
    }
}
