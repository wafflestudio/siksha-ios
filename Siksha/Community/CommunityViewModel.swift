//
//  CommunityViewModel.swift
//  Siksha
//
//  Created by 한상현 on 2023/09/18.
//

import Foundation
import Combine

struct PostInfo: Identifiable, Equatable {
    let boardId: Int
    let nickname: String?
    let profileUrl: String?
    let id: Int
    let title: String
    let content: String
    let createdAt: Date
    let isLiked: Bool
    let likeCount: Int
    let commentCount: Int
    let imageURLs: [String]?
    let isAnonymous: Bool
    let isMine: Bool
    let isAvailable: Bool
    
    init(post: Post) {
        self.boardId = post.boardId
        self.nickname = post.nickname
        self.profileUrl = post.profileUrl
        self.id = post.id
        self.title = post.title
        self.content = post.content
        self.createdAt = post.createdAt
        self.isLiked = post.isLiked
        self.likeCount = post.likeCnt
        self.commentCount = post.commentCnt
        self.imageURLs = post.images
        self.isAnonymous = post.anonymous
        self.isMine = post.isMine
        self.isAvailable = post.available
    }
    
    init(title: String, content: String, isLiked: Bool, likeCount: Int, commentCount: Int, imageURLs: [String]?,isAnonymous:Bool,isMine:Bool) {
        self.title = title
        self.content = content
        self.isLiked = isLiked
        self.likeCount = likeCount
        self.commentCount = commentCount
        self.imageURLs = imageURLs
        
        self.boardId = 0
        self.nickname = ""
        self.createdAt = Date()
        self.id = 0
        self.profileUrl = nil
        self.isAnonymous = isAnonymous
        self.isMine = isMine
        self.isAvailable = true
    }
}

struct BoardInfo: Hashable {
    let id: Int
    let type: Int
    let name: String
    let isSelected: Bool
    
    init(id: Int, type: Int, name: String, isSelected: Bool) {
        self.id = id
        self.type = type
        self.name = name
        self.isSelected = isSelected
    }
    
    init(board: Board, isSelected: Bool) {
        self.id = board.id
        self.type = board.type
        self.name = board.name
        self.isSelected = isSelected
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

protocol CommunityViewModelType: ObservableObject {
    var boardsListPublisher: [BoardInfo] { get }
    var postsListPublisher: [PostInfo] { get }
    var trendingPostsListPublisher: [PostInfo] { get }
    var hasNextPublisher: Bool { get }
    
    func selectBoard(id: Int)
    func loadBasicInfos()
    func loadMorePosts()
    func getSelectedBoardName() -> String
    func loadSelectedBoardPosts()
}

final class CommunityViewModel: CommunityViewModelType {
    struct Constants {
        static let initialPage = 1
        static let pageCount = 20
        static let trendingLikes = 10
        static let trendingCreatedBefore = 7
    }
    
    private let communityRepository: CommunityRepositoryProtocol
    
    @Published private var boardsList: [Board] = []
    @Published private var selectedBoardId: Int = 0
    
    @Published private var currPostList: [Post] = []
    @Published private var trendingPostList: [Post] = []
    private var currentPage: Int = 0
    
    @Published private var hasNext: Bool = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init(communityRepository: CommunityRepositoryProtocol) {
        self.communityRepository = communityRepository
    }
}

extension CommunityViewModel {
    var boardsListPublisher: [BoardInfo] {
        let selectedId = self.selectedBoardId
        let boardList = self.boardsList
        
        return boardList
            .map { board in
                return BoardInfo(board: board, isSelected: board.id == selectedId)
            }
    }
    
    var postsListPublisher: [PostInfo] {
        return self.currPostList
            .map { PostInfo(post: $0 )}
    }
    
    var hasNextPublisher: Bool {
        return self.hasNext
    }
    var trendingPostsListPublisher: [PostInfo]{
        return self.trendingPostList.map{PostInfo(post: $0 )}
    }
}

extension CommunityViewModel {
    func loadBasicInfos() {
        self.loadBoards()
        self.loadTrendingPosts()
    }
    
    private func loadBoards() {
        self.communityRepository
            .loadBoardList()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { error in
                print(error)
            }, receiveValue: { [weak self] boards in
                self?.boardsList = boards
                self?.selectBoard(id: boards.first?.id ?? 0)
            })
            .store(in: &cancellables)
    }
    
    private func loadTrendingPosts() {
        self.communityRepository.loadTrendingPosts(likes:Constants.trendingLikes, created_before: Constants.trendingCreatedBefore)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { error in
                print(error)
            }, receiveValue: {[weak self] response in
                self?.trendingPostList = response.result
                
            })
            .store(in: &cancellables)
    }
    
    func selectBoard(id: Int) {
        self.selectedBoardId = id
        
        self.loadInitialPosts(boardId: id)
    }
    
    func getSelectedBoardName() -> String {
        boardsListPublisher.first { $0.isSelected }?.name ?? "Unknown"
    }
    
    private func loadInitialPosts(boardId: Int) {
        self.communityRepository
            .loadPostsPage(boardId: boardId, page: Constants.initialPage, perPage: Constants.pageCount)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { error in
                print(error)
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
            .loadPostsPage(boardId: self.selectedBoardId, page: self.currentPage + 1, perPage: Constants.pageCount)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { error in
                print(error)
            }, receiveValue: { [weak self] postsPage in
                self?.currPostList.append(contentsOf: postsPage.posts)
                self?.currentPage += 1
                self?.hasNext = postsPage.hasNext
            })
            .store(in: &cancellables)
    }
    func loadSelectedBoardPosts() {
        loadInitialPosts(boardId: selectedBoardId)
    }
}
