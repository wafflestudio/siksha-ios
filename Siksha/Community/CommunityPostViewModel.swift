//
//  CommunityPostViewModel.swift
//  Siksha
//
//  Created by Chaehyun Park on 2023/11/29.
//

import Foundation
import Combine

struct CommentInfo: Identifiable, Equatable {
    let id: Int
    let postId: Int
    let content: String
    let createdAt: Date
    let updatedAt: Date
    let nickname: String
    let profileUrl: String?
    let available: Bool
    let likeCnt: Int
    let isLiked: Bool
    let isAnonymous: Bool
    let isMine: Bool
    
    init(comment: Comment) {
        self.id = comment.id
        self.postId = comment.postId
        self.content = comment.content
        self.createdAt = comment.createdAt
        self.updatedAt = comment.updatedAt
        self.nickname = comment.nickname ?? "익명"
        self.profileUrl = comment.profileUrl
        self.available = comment.available
        self.likeCnt = comment.likeCnt
        self.isLiked = comment.isLiked
        self.isAnonymous = comment.anonymous
        self.isMine = comment.isMine
    }

    init(content: String, likeCnt: Int, isLiked: Bool) {
        self.id = 1
        self.postId = 1
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
        self.nickname = ""
        self.profileUrl = nil
        self.available = true
        self.likeCnt = likeCnt
        self.isLiked = isLiked
        self.isAnonymous = false
        self.isMine = false
    }
    
}

protocol CommunityPostViewModelType: ObservableObject {
    var postInfo: PostInfo { get }
    var commentsListPublisher: [CommentInfo] { get }
    var hasNextPublisher: Bool { get }
    var boardNamePublisher: String { get }
    
    func editPost()
    func deletePost(completion: @escaping (Bool) -> Void)
    func togglePostLike()
    func loadBasicInfos()
    func loadMoreComments()
    func submitComment(postId: Int, content: String, isAnonymous: Bool)
    func editComment(commentId: Int, content: String)
    func deleteComment(id: Int,completion:@escaping(Bool)->Void)
    func toggleCommentLike(id: Int)
    func reportPost(reason: String, completion: @escaping (Bool, String?) -> Void)
    func reportComment(commentId:Int,reason:String, completion: @escaping (Bool, String?) -> Void)
}

final class CommunityPostViewModel: CommunityPostViewModelType {
    struct Constants {
        static let initialPage = 1
        static let pageCount = 10
    }
    
    private let postId: Int
    
    private let communityRepository: CommunityRepositoryProtocol
    
    @Published private var post: Post
    @Published private var commentsList: [Comment] = []
    @Published private var boardsList: [Board] = []
    @Published private var hasNext: Bool = false
    @Published var reportAlert:Bool = false
    @Published var reportErrorAlert:Bool = false

    private var currentPage: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    
    init(communityRepository: CommunityRepositoryProtocol, postId: Int) {
        self.communityRepository = communityRepository
        self.postId = postId
        print("POST ID: \(postId)")
        self.post = Post()
    }
}

extension CommunityPostViewModel {
    var commentsListPublisher: [CommentInfo] {
        return self.commentsList
            .map { CommentInfo(comment: $0 )}
    }
    
    var postInfo: PostInfo {
        return PostInfo(post: self.post)
    }
    
    var hasNextPublisher: Bool {
        return self.hasNext
    }
    var boardNamePublisher: String {
        for board in boardsList{
            if board.id == postInfo.boardId{
                return board.name
            }
        }
        return ""
    }
}

extension CommunityPostViewModel {
    func loadBasicInfos() {
        self.loadPost()
        self.loadInitialComments()
        self.loadBoardInfo()
    }
    
    func editPost() {
        
    }
    
    func deletePost(completion: @escaping (Bool) -> Void) {
        self.communityRepository.deletePost(postId: self.postId)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                switch completionStatus {
                case .finished:
                    completion(true)
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }, receiveValue: { value in
                
            })
            .store(in: &cancellables)
    }

    func togglePostLike() {
        if self.post.isLiked {
            self.communityRepository.unlikePost(postId: self.postId)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { error in
                    print(error)
                }, receiveValue: { [weak self] post in
                    self?.post = post
                })
                .store(in: &cancellables)
        } else {
            self.communityRepository.likePost(postId: self.postId)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { error in
                    print(error)
                }, receiveValue: { [weak self] post in
                    self?.post = post
                })
                .store(in: &cancellables)
        }
    }
    private func loadBoardInfo(){
        self.communityRepository.loadBoardList()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion:{
                error in
                print(error)
            },receiveValue: {[weak self] boards in
                self?.boardsList = boards
            })
            .store(in: &cancellables)
    }
    private func loadPost() {
        self.communityRepository
            .loadPost(postId: self.postId)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { error in
                print(error)
            }, receiveValue: { [weak self] post in
                self?.post = post
            })
            .store(in: &cancellables)
    }
    
 
    
    private func loadInitialComments() {
        self.communityRepository
            .loadCommentsPage(postId: self.postId, page: Constants.initialPage, perPage: Constants.pageCount)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { error in
                print(error)
            }, receiveValue: { [weak self] commentsPage in
                self?.commentsList = commentsPage.comments
                self?.currentPage = 1
                self?.hasNext = commentsPage.hasNext
            })
            .store(in: &cancellables)
    }
    
    func loadMoreComments() {
        guard self.hasNext == true else {
            return
        }
        
        self.communityRepository
            .loadCommentsPage(postId: self.postId, page: self.currentPage + 1, perPage: Constants.pageCount)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { error in
                print(error)
            }, receiveValue: { [weak self] commentsPage in
                self?.commentsList.append(contentsOf: commentsPage.comments)
                self?.currentPage += 1
                self?.hasNext = commentsPage.hasNext
            })
            .store(in: &cancellables)
    }
    
    
    func submitComment(postId: Int, content: String,isAnonymous:Bool) {
        communityRepository.postComment(postId: postId, content: content,anonymous: isAnonymous)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { error in
                    print(error)
                }, receiveValue: { [weak self] newComment in
                self?.commentsList.append(newComment)
            })
            .store(in: &cancellables)
    }
    func editComment(commentId: Int, content: String) {
        self.communityRepository.editComment(commentId: commentId, content: content)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { error in
                print(error)
            }, receiveValue: { [weak self] updatedComment in
                if let index = self?.commentsList.firstIndex(where: { $0.id == updatedComment.id }) {
                    self?.commentsList[index] = updatedComment
                }
            })
            .store(in: &cancellables)
    }

    func deleteComment(id:Int,completion: @escaping (Bool) -> Void) {
        self.communityRepository.deleteComment(commentId: id)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] completionStatus in
                switch completionStatus {
                case .finished:
                    completion(true)
                case .failure(let error):
                    print(error)
                    completion(false)
                }
            }, receiveValue: { value in
                
            })
            .store(in: &cancellables)
    }
    
    func toggleCommentLike(id: Int) {
        guard let index = self.commentsList.firstIndex(where: { $0.id == id }) else {
            return
        }

        let comment = self.commentsList[index]

        if comment.isLiked {
            self.communityRepository.unlikeComment(commentId: id)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error occurred while unliking the comment: \(error)")
                    }
                }, receiveValue: { [weak self] updatedComment in
                    self?.commentsList[index] = updatedComment
                })
                .store(in: &cancellables)
        } else {
            self.communityRepository.likeComment(commentId: id)
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("Error occurred while liking the comment: \(error)")
                    }
                }, receiveValue: { [weak self] updatedComment in
                    self?.commentsList[index] = updatedComment
                })
                .store(in: &cancellables)
        }
    }
    
    func reportPost(reason: String, completion: @escaping (Bool, String?) -> Void) {
        self.communityRepository.reportPost(postId: postId, reason: reason).receive(on: RunLoop.main)
            .sink(receiveCompletion: { completionStatus in
                switch completionStatus {
                case .finished:
                    break
                case .failure(let error):
                    completion(false, "신고에 실패했습니다. 이미 신고한 게시물일 수 있습니다.")
                }
            }, receiveValue: { _ in
                completion(true, nil)
            })
            .store(in: &cancellables)
    }
    
    func reportComment(commentId: Int, reason: String, completion: @escaping (Bool, String?) -> Void) {
        self.communityRepository.reportComment(commentId: commentId, reason: reason).receive(on: RunLoop.main)
            .sink(receiveCompletion: { completionStatus in
                switch completionStatus {
                case .finished:
                    break
                case .failure(let error):
                    completion(false, "신고에 실패했습니다. 이미 신고한 게시물일 수 있습니다.")
                }
            }, receiveValue: { _ in
                completion(true, nil)
            })
            .store(in: &cancellables)
    }

}
