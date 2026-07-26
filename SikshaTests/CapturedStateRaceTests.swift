//
//  CapturedStateRaceTests.swift
//  SikshaTests
//

import Combine
import UIKit
import XCTest

@testable import Siksha

@MainActor
final class CapturedStateRaceTests: XCTestCase {
    func testKeywordFlowLayoutWrapsUsingTallestItemInEachRow() {
        let layout = KeywordFlowLayout(horizontalSpacing: 6, verticalSpacing: 6)

        let arrangement = layout.arrangement(
            for: [
                CGSize(width: 40, height: 20),
                CGSize(width: 50, height: 30),
                CGSize(width: 30, height: 10),
            ],
            availableWidth: 100
        )

        XCTAssertEqual(arrangement.origins, [CGPoint(x: 0, y: 0), CGPoint(x: 46, y: 0), CGPoint(x: 0, y: 36)])
        XCTAssertEqual(arrangement.size, CGSize(width: 100, height: 46))
    }

    func testKeywordFlowLayoutPlacesOversizedItemOnItsOwnRow() {
        let layout = KeywordFlowLayout(horizontalSpacing: 6, verticalSpacing: 6)

        let arrangement = layout.arrangement(
            for: [CGSize(width: 120, height: 20), CGSize(width: 30, height: 40)],
            availableWidth: 80
        )

        XCTAssertEqual(arrangement.origins, [CGPoint(x: 0, y: 0), CGPoint(x: 0, y: 26)])
        XCTAssertEqual(arrangement.size, CGSize(width: 80, height: 66))
    }

    func testOrderedImageLoaderFailsWhenAnyResponseIsRejected() async throws {
        let rejectedURL = try XCTUnwrap(URL(string: "https://example.com/rejected.png"))
        let transport = ImageDataTransportStub(results: [
            rejectedURL: .success((Data([0x03]), response(url: rejectedURL, statusCode: 500)))
        ])
        let loader = URLSessionOrderedImageDataLoader(transport: transport)

        do {
            _ = try await loader.loadImageData(from: [rejectedURL])
            XCTFail("Expected invalid response error")
        } catch OrderedImageDataLoadingError.invalidResponse {
        } catch {
            XCTFail("Expected invalid response error, got \(error)")
        }
    }

    func testOrderedImageLoaderPropagatesCancellation() async throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/image.png"))
        let transport = ControlledImageDataTransport()
        let loader = URLSessionOrderedImageDataLoader(transport: transport)
        let task = Task {
            try await loader.loadImageData(from: [url])
        }
        await transport.waitUntilRequested(url)

        task.cancel()
        await transport.succeed(url: url, data: Data([0x01]))

        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch is CancellationError {
        } catch {
            XCTFail("Expected CancellationError, got \(error)")
        }
    }

    func testOrderedImageLoaderPreservesOrderWhenRequestsFinishOutOfOrder() async throws {
        let firstURL = try XCTUnwrap(URL(string: "https://example.com/first.png"))
        let secondURL = try XCTUnwrap(URL(string: "https://example.com/second.png"))
        let firstData = Data([0x01])
        let secondData = Data([0x02])
        let transport = ControlledImageDataTransport()
        let loader = URLSessionOrderedImageDataLoader(transport: transport)
        let task = Task {
            try await loader.loadImageData(from: [firstURL, secondURL])
        }
        await transport.waitUntilRequested([firstURL, secondURL])

        await transport.succeed(url: secondURL, data: secondData)
        await transport.succeed(url: firstURL, data: firstData)

        let data = try await task.value
        XCTAssertEqual(data, [firstData, secondData])
    }

    func testLatestCommunityImageRequestWinsAndPreservesImageOrder() async throws {
        let firstURL = "https://example.com/first.png"
        let secondURL = "https://example.com/second.png"
        let thirdURL = "https://example.com/third.png"
        let loader = ControlledOrderedImageDataLoader()
        let firstImageData = try XCTUnwrap(makeImage(size: CGSize(width: 5, height: 5)).pngData())
        let secondImageData = try XCTUnwrap(makeImage(size: CGSize(width: 10, height: 5)).pngData())
        let thirdImageData = try XCTUnwrap(makeImage(size: CGSize(width: 20, height: 5)).pngData())
        let viewModel = CommunityPostPublishViewModel(
            boardId: 1,
            communityRepository: CommunityRepositoryStub(),
            orderedImageDataLoader: loader,
            uploadImagePreparer: JPEGUploadImagePreparer(),
            postInfo: makePostInfo(imageURLs: [firstURL])
        )
        await loader.waitForRequestCount(1)

        viewModel.loadImages(from: [secondURL, thirdURL])
        await loader.waitForRequestCount(2)
        await loader.completeRequest(at: 1, with: [secondImageData, thirdImageData])
        await waitUntil { viewModel.imageAttachments.count == 2 }

        await loader.completeRequest(at: 0, with: [firstImageData])
        for _ in 0..<10 {
            await Task.yield()
        }

        assertImageOrder(viewModel.imageAttachments.map(\.previewImage))
    }

    func testDownloadedImageDataIsNotRecompressedWhenEditingCommunityPost() async throws {
        let existingURL = "https://example.com/existing.png"
        let loader = ControlledOrderedImageDataLoader()
        let repository = CommunityRepositoryStub()
        let existingData = try XCTUnwrap(makeImage(size: CGSize(width: 5, height: 5)).pngData())
        let selectedImage = makeImage(size: CGSize(width: 10, height: 10))
        let expectedSelectedData = try XCTUnwrap(selectedImage.jpegData(compressionQuality: 0.5))
        let viewModel = CommunityPostPublishViewModel(
            boardId: 1,
            communityRepository: repository,
            orderedImageDataLoader: loader,
            uploadImagePreparer: JPEGUploadImagePreparer(),
            postInfo: makePostInfo(imageURLs: [existingURL])
        )
        await loader.waitForRequestCount(1)
        await loader.completeRequest(at: 0, with: [existingData])
        await waitUntil { viewModel.existingImageLoadState == .ready }

        viewModel.addSelectedImages([selectedImage])
        viewModel.submitPost()

        XCTAssertEqual(repository.lastEditedImages, [existingData, expectedSelectedData])
        XCTAssertEqual(viewModel.imageAttachments.map(\.origin), [.downloaded, .selected])
    }

    func testDownloadedAttachmentKeepsOriginalBytesAndSelectedAttachmentUsesJPEG() throws {
        let preparer = JPEGUploadImagePreparer()
        let image = makeImage(size: CGSize(width: 8, height: 8))
        let downloadedData = try XCTUnwrap(image.pngData())

        let downloaded = try preparer.prepareDownloadedImage(data: downloadedData)
        let selected = try preparer.prepareSelectedImage(image)

        XCTAssertEqual(downloaded.uploadData, downloadedData)
        XCTAssertEqual(downloaded.origin, .downloaded)
        XCTAssertEqual(selected.uploadData, image.jpegData(compressionQuality: 0.5))
        XCTAssertEqual(selected.origin, .selected)
    }

    private func response(url: URL, statusCode: Int) -> HTTPURLResponse {
        HTTPURLResponse(url: url, statusCode: statusCode, httpVersion: nil, headerFields: nil)!
    }

    private func makeImage(size: CGSize) -> UIImage {
        UIGraphicsImageRenderer(size: size).image { context in
            UIColor.orange.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    private func assertImageOrder(
        _ images: [UIImage],
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        XCTAssertEqual(images.count, 2, file: file, line: line)
        let imageWidths = images.map(\.size.width)
        XCTAssertLessThan(imageWidths[0], imageWidths[1], file: file, line: line)
        XCTAssertEqual(imageWidths[1] / imageWidths[0], 2, file: file, line: line)
    }

    private func makePostInfo(imageURLs: [String]) -> PostInfo {
        PostInfo(
            title: "Title",
            content: "Content",
            isLiked: false,
            likeCount: 0,
            commentCount: 0,
            imageURLs: imageURLs,
            isAnonymous: false,
            isMine: true
        )
    }

    private func waitUntil(
        _ condition: () -> Bool,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        for _ in 0..<1_000 {
            if condition() {
                return
            }
            await Task.yield()
        }
        XCTFail("Condition was not satisfied", file: file, line: line)
    }
}

private enum TestError: Error {
    case failed
    case unexpectedRequest
}

private actor ImageDataTransportStub: ImageDataTransporting {
    private let results: [URL: Result<(Data, URLResponse), Error>]
    private(set) var requestedURLs: [URL] = []

    init(results: [URL: Result<(Data, URLResponse), Error>]) {
        self.results = results
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        requestedURLs.append(url)
        guard let result = results[url] else {
            throw TestError.unexpectedRequest
        }
        return try result.get()
    }
}

private actor ControlledImageDataTransport: ImageDataTransporting {
    private var requestedURLs: Set<URL> = []
    private var continuations: [URL: CheckedContinuation<(Data, URLResponse), Error>] = [:]

    func data(from url: URL) async throws -> (Data, URLResponse) {
        requestedURLs.insert(url)
        return try await withCheckedThrowingContinuation { continuation in
            continuations[url] = continuation
        }
    }

    func waitUntilRequested(_ url: URL) async {
        while !requestedURLs.contains(url) {
            await Task.yield()
        }
    }

    func waitUntilRequested(_ urls: Set<URL>) async {
        while !requestedURLs.isSuperset(of: urls) {
            await Task.yield()
        }
    }

    func succeed(url: URL, data: Data) {
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)!
        continuations.removeValue(forKey: url)?.resume(returning: (data, response))
    }
}

private actor ControlledOrderedImageDataLoader: OrderedImageDataLoading {
    private var continuations: [CheckedContinuation<[Data], Error>?] = []

    func loadImageData(from urls: [URL]) async throws -> [Data] {
        try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func waitForRequestCount(_ count: Int) async {
        while continuations.count < count {
            await Task.yield()
        }
    }

    func completeRequest(at index: Int, with data: [Data]) {
        continuations[index]?.resume(returning: data)
        continuations[index] = nil
    }
}

private final class CommunityRepositoryStub: CommunityRepositoryProtocol {
    private(set) var lastSubmittedImages: [Data]?
    private(set) var lastEditedImages: [Data]?

    func loadBoardList() -> AnyPublisher<[Board], AppError> {
        Empty().eraseToAnyPublisher()
    }

    func submitPost(
        boardId: Int,
        title: String,
        content: String,
        images: [Data],
        anonymous: Bool
    ) -> AnyPublisher<SubmitPostResponse, AppError> {
        lastSubmittedImages = images
        return Empty().eraseToAnyPublisher()
    }

    func editPost(
        postId: Int,
        boardId: Int,
        title: String,
        content: String,
        images: [Data],
        anonymous: Bool
    ) -> AnyPublisher<SubmitPostResponse, AppError> {
        lastEditedImages = images
        return Empty().eraseToAnyPublisher()
    }

    func loadPostsPage(boardId: Int, page: Int, perPage: Int) -> AnyPublisher<PostsPage, AppError> {
        fatalError("Unused")
    }

    func loadTrendingPosts(likes: Int, created_before: Int) -> AnyPublisher<TrendingPostsResponse, AppError> {
        fatalError("Unused")
    }

    func loadMyPostsPage(page: Int, perPage: Int) -> AnyPublisher<PostsPage, AppError> {
        fatalError("Unused")
    }

    func loadPost(postId: Int) -> AnyPublisher<Post, AppError> {
        fatalError("Unused")
    }

    func deletePost(postId: Int) -> AnyPublisher<Void, AppError> {
        fatalError("Unused")
    }

    func likePost(postId: Int) -> AnyPublisher<Post, AppError> {
        fatalError("Unused")
    }

    func unlikePost(postId: Int) -> AnyPublisher<Post, AppError> {
        fatalError("Unused")
    }

    func loadCommentsPage(postId: Int, page: Int, perPage: Int) -> AnyPublisher<CommentsPage, AppError> {
        fatalError("Unused")
    }

    func postComment(postId: Int, content: String, anonymous: Bool) -> AnyPublisher<Comment, AppError> {
        fatalError("Unused")
    }

    func editComment(commentId: Int, content: String) -> AnyPublisher<Comment, AppError> {
        fatalError("Unused")
    }

    func deleteComment(commentId: Int) -> AnyPublisher<Void, AppError> {
        fatalError("Unused")
    }

    func likeComment(commentId: Int) -> AnyPublisher<Comment, AppError> {
        fatalError("Unused")
    }

    func unlikeComment(commentId: Int) -> AnyPublisher<Comment, AppError> {
        fatalError("Unused")
    }

    func reportPost(postId: Int, reason: String) -> AnyPublisher<PostReportResponse, AppError> {
        fatalError("Unused")
    }

    func reportComment(commentId: Int, reason: String) -> AnyPublisher<CommentReportResponse, AppError> {
        fatalError("Unused")
    }
}
