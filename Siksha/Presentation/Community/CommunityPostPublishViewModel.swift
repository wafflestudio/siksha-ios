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
    var imageAttachments: [UploadImageAttachment] { get }
    var existingImageLoadState: ExistingImageLoadState { get }
    var isSubmitted: Bool { get set }
    var isErrorAlert: Bool { get set }
    var boardId: Int { get }
    var postInfo: PostInfo? { get set }
    var canSubmit: Bool { get }
    var remainingImageCount: Int { get }
    func submitPost()
    func addSelectedImages(_ images: [UIImage])
    func removeImage(id: UUID)
    func retryExistingImageLoad()
}

@MainActor
final class CommunityPostPublishViewModel: CommunityPostPublishViewType {
    private enum Constants {
        static let maxImageCount = 5
    }

    var postInfo: PostInfo?
    private let communityRepository: CommunityRepositoryProtocol
    private let orderedImageDataLoader: OrderedImageDataLoading
    private let uploadImagePreparer: UploadImagePreparing
    private var cancellables = Set<AnyCancellable>()
    private var imageLoadTask: Task<Void, Never>?
    private var imageLoadGeneration = 0
    private var existingImageURLStrings: [String] = []

    @Published var boardId: Int
    @Published var boardsList: [Board] = []
    @Published var content = ""
    @Published var title = ""
    @Published var isAnonymous: Bool {
        didSet {
            UserDefaults.standard.set(isAnonymous, forKey: "isAnonymous")
        }
    }
    @Published private(set) var imageAttachments: [UploadImageAttachment] = []
    @Published private(set) var existingImageLoadState: ExistingImageLoadState = .ready
    @Published private(set) var isSubmitting = false
    @Published var isSubmitted = false
    @Published var isErrorAlert = false

    init(
        boardId: Int,
        communityRepository: CommunityRepositoryProtocol,
        orderedImageDataLoader: OrderedImageDataLoading,
        uploadImagePreparer: UploadImagePreparing,
        postInfo: PostInfo? = nil
    ) {
        self.boardId = boardId
        self.communityRepository = communityRepository
        self.orderedImageDataLoader = orderedImageDataLoader
        self.uploadImagePreparer = uploadImagePreparer
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

    var canSubmit: Bool {
        !title.isEmpty && !content.isEmpty && existingImageLoadState == .ready && !isSubmitting
    }

    var remainingImageCount: Int {
        max(0, Constants.maxImageCount - imageAttachments.count)
    }

    func submitPost() {
        guard canSubmit else { return }

        isSubmitting = true
        isSubmitted = false
        let images = imageAttachments.map(\.uploadData)
        let publisher: AnyPublisher<SubmitPostResponse, AppError>

        if let info = postInfo {
            publisher = communityRepository.editPost(
                postId: info.id, boardId: boardId, title: title, content: content,
                images: images, anonymous: isAnonymous
            )
        } else {
            publisher = communityRepository.submitPost(
                boardId: boardId, title: title, content: content, images: images, anonymous: isAnonymous
            )
        }

        publisher
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    self.isSubmitting = false
                    if case .failure = completion {
                        self.isSubmitted = false
                        self.isErrorAlert = true
                    }
                },
                receiveValue: { [weak self] _ in
                    guard let self else { return }
                    self.isSubmitted = true
                    self.isErrorAlert = true
                }
            )
            .store(in: &cancellables)
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
        existingImageURLStrings = urlStrings
        imageLoadGeneration += 1
        let generation = imageLoadGeneration
        imageLoadTask?.cancel()
        existingImageLoadState = .loading

        let urls = urlStrings.compactMap(URL.init(string:))
        guard urls.count == urlStrings.count else {
            existingImageLoadState = .failed
            return
        }
        guard !urls.isEmpty else {
            imageAttachments.removeAll { $0.origin == .downloaded }
            existingImageLoadState = .ready
            return
        }

        let orderedImageDataLoader = orderedImageDataLoader
        imageLoadTask = Task { @concurrent [weak self] in
            do {
                let loadedData = try await orderedImageDataLoader.loadImageData(from: urls)
                try Task.checkCancellation()
                await self?.applyLoadedImageData(loadedData, generation: generation)
            } catch is CancellationError {
                return
            } catch {
                await self?.applyImageLoadFailure(generation: generation)
            }
        }
    }

    func addSelectedImages(_ images: [UIImage]) {
        let imagesToAdd = images.prefix(remainingImageCount)

        do {
            let attachments = try imagesToAdd.map(uploadImagePreparer.prepareSelectedImage)
            imageAttachments.append(contentsOf: attachments)
        } catch {
            isSubmitted = false
            isErrorAlert = true
        }
    }

    func removeImage(id: UUID) {
        imageAttachments.removeAll { $0.id == id }
    }

    func retryExistingImageLoad() {
        loadImages(from: existingImageURLStrings)
    }

    private func applyLoadedImageData(_ loadedData: [Data], generation: Int) {
        guard imageLoadGeneration == generation else { return }

        do {
            let downloadedAttachments = try loadedData.map(uploadImagePreparer.prepareDownloadedImage)
            let selectedAttachments = imageAttachments.filter { $0.origin == .selected }
            imageAttachments = downloadedAttachments + selectedAttachments
            existingImageLoadState = .ready
        } catch {
            existingImageLoadState = .failed
        }
    }

    private func applyImageLoadFailure(generation: Int) {
        guard imageLoadGeneration == generation else { return }
        existingImageLoadState = .failed
    }
}
