//
//  CommunitySubmitPostViewModel.swift
//  Siksha
//
//  Created by 박정헌 on 2023/12/02.
//

import Combine
import Foundation
import UIKit

@MainActor
protocol CommunityPostPublishViewType: ObservableObject {
    var content: String { get set }
    var title: String { get set }
    var isAnonymous: Bool { get set }
    var images: [UIImage] { get set }
    var isSubmitted: Bool { get set }
    var isErrorAlert: Bool { get set }
    var boardId: Int { get }
    var postInfo: PostInfo? { get set }
    func submitPost()

}
@MainActor
final class CommunityPostPublishViewModel: CommunityPostPublishViewType {
    var postInfo: PostInfo?
    private let communityRepository: CommunityRepositoryProtocol
    private let orderedImageDataLoader: OrderedImageDataLoading
    private var cancellables = Set<AnyCancellable>()
    private var imageLoadTask: Task<Void, Never>?
    private var imageLoadGeneration = 0
    @Published var boardId: Int
    @Published var boardsList: [Board] = []
    @Published var content = ""
    @Published var title = ""
    @Published var isAnonymous: Bool {
        didSet {
            UserDefaults.standard.set(isAnonymous, forKey: "isAnonymous")
        }
    }
    @Published var images: [UIImage] = []
    @Published var isSubmitted = false
    @Published var isErrorAlert = false
    init(
        boardId: Int,
        communityRepository: CommunityRepositoryProtocol,
        orderedImageDataLoader: OrderedImageDataLoading,
        postInfo: PostInfo? = nil
    ) {
        self.boardId = boardId
        self.communityRepository = communityRepository
        self.orderedImageDataLoader = orderedImageDataLoader
        self.isAnonymous = UserDefaults.standard.bool(forKey: "isAnonymous")

        loadBoardInfo()

        if let info = postInfo {
            self.postInfo = info
            self.title = info.title
            self.content = info.content
            self.isAnonymous = info.isAnonymous
            if let imageURLs = info.imageURLs {
                loadImages(from: imageURLs)
            }
        }
    }

    deinit {
        imageLoadTask?.cancel()
    }

    func submitPost() {
        if let info = postInfo { //edit
            print("info.id")
            print(info.id)
            print(images.count)
            communityRepository.editPost(
                postId: info.id, boardId: boardId, title: title, content: content,
                images: images.map { image in image.pngData()! }, anonymous: isAnonymous
            ).sink(
                receiveCompletion: { [weak self] error in
                    print(error)
                    self?.isErrorAlert = true
                },
                receiveValue: { [weak self] response in
                    self?.isSubmitted = true

                }
            ).store(in: &cancellables)
        } else { //submit
            print("submit new")
            communityRepository.submitPost(
                boardId: boardId, title: title, content: content, images: images.map { image in image.pngData()! },
                anonymous: isAnonymous
            ).sink(
                receiveCompletion: { [weak self] error in
                    print(error)
                    self?.isErrorAlert = true
                },
                receiveValue: { [weak self] response in
                    self?.isSubmitted = true

                }
            ).store(in: &cancellables)
        }
    }

    private func loadBoardInfo() {
        self.communityRepository.loadBoardList()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: {
                    error in
                    print(error)
                },
                receiveValue: { [weak self] boards in
                    self?.boardsList = boards
                }
            )
            .store(in: &cancellables)
    }

    func loadImages(from urlStrings: [String]) {
        imageLoadGeneration += 1
        let generation = imageLoadGeneration
        imageLoadTask?.cancel()

        let urls = urlStrings.compactMap(URL.init(string:))
        guard !urls.isEmpty else {
            images = []
            return
        }

        let orderedImageDataLoader = orderedImageDataLoader
        imageLoadTask = Task { [weak self] in
            do {
                let loadedData = try await orderedImageDataLoader.loadImageData(from: urls)
                try Task.checkCancellation()
                let loadedImages = loadedData.compactMap(UIImage.init(data:))
                guard let self, self.imageLoadGeneration == generation else { return }
                self.images = loadedImages
            } catch {
                return
            }
        }
    }

    func removeImage(_ image: UIImage) {
        self.images.removeAll(where: { $0 == image })
        print(self.images.count)
    }

}
