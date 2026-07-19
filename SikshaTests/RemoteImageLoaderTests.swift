//
//  RemoteImageLoaderTests.swift
//  SikshaTests
//

import UIKit
import XCTest

@testable import Siksha

@MainActor
final class RemoteImageLoaderTests: XCTestCase {
    func testCacheHitSkipsNetworkRequest() async throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/cached.png"))
        let cachedImage = makeImage(color: .orange)
        let cache = ImageCacheStub()
        cache[url] = cachedImage
        let dataLoader = RemoteImageDataLoaderStub(result: .failure(TestError.unexpectedRequest))
        let loader = RemoteImageLoader(dataLoader: dataLoader)

        await loader.load(url: url.absoluteString, cache: cache)

        let requestCount = await dataLoader.requestCount
        XCTAssertEqual(requestCount, 0)
        assertSuccess(loader.phase, expectedImage: cachedImage)
    }

    func testDownloadedImageIsStoredInCache() async throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/downloaded.png"))
        let downloadedImage = makeImage(color: .blue)
        let imageData = try XCTUnwrap(downloadedImage.pngData())
        let response = try XCTUnwrap(
            HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ))
        let cache = ImageCacheStub()
        let dataLoader = RemoteImageDataLoaderStub(result: .success((imageData, response)))
        let loader = RemoteImageLoader(dataLoader: dataLoader)

        await loader.load(url: url.absoluteString, cache: cache)

        let requestCount = await dataLoader.requestCount
        XCTAssertEqual(requestCount, 1)
        XCTAssertNotNil(cache[url])
        assertSuccess(loader.phase)
    }

    func testInvalidImageDataProducesFailedPhase() async throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/invalid.png"))
        let response = try XCTUnwrap(
            HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ))
        let dataLoader = RemoteImageDataLoaderStub(result: .success((Data([0x00]), response)))
        let loader = RemoteImageLoader(dataLoader: dataLoader)

        await loader.load(url: url.absoluteString, cache: ImageCacheStub())

        guard case .failed = loader.phase else {
            return XCTFail("Expected failed phase")
        }
    }

    func testMissingCacheStillDownloadsImage() async throws {
        let url = try XCTUnwrap(URL(string: "https://example.com/uncached.png"))
        let imageData = try XCTUnwrap(makeImage(color: .purple).pngData())
        let response = try XCTUnwrap(
            HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            ))
        let dataLoader = RemoteImageDataLoaderStub(result: .success((imageData, response)))
        let loader = RemoteImageLoader(dataLoader: dataLoader)

        await loader.load(url: url.absoluteString, cache: nil)

        let requestCount = await dataLoader.requestCount
        XCTAssertEqual(requestCount, 1)
        assertSuccess(loader.phase)
    }

    func testCancelledOldRequestCannotOverwriteLatestImage() async throws {
        let firstURL = try XCTUnwrap(URL(string: "https://example.com/first.png"))
        let secondURL = try XCTUnwrap(URL(string: "https://example.com/second.png"))
        let firstImageData = try XCTUnwrap(makeImage(color: .red).pngData())
        let secondImage = makeImage(color: .green)
        let secondImageData = try XCTUnwrap(secondImage.pngData())
        let dataLoader = ControlledRemoteImageDataLoader()
        let loader = RemoteImageLoader(dataLoader: dataLoader)
        let cache = ImageCacheStub()

        let firstTask = Task {
            await loader.load(url: firstURL.absoluteString, cache: cache)
        }
        await dataLoader.waitUntilRequested(firstURL)

        firstTask.cancel()
        let secondTask = Task {
            await loader.load(url: secondURL.absoluteString, cache: cache)
        }
        await dataLoader.waitUntilRequested(secondURL)

        await dataLoader.succeed(url: firstURL, data: firstImageData)
        await firstTask.value
        await dataLoader.succeed(url: secondURL, data: secondImageData)
        await secondTask.value

        XCTAssertNil(cache[firstURL])
        let cachedSecondImage = try XCTUnwrap(cache[secondURL])
        assertSuccess(loader.phase, expectedImage: cachedSecondImage)
    }

    private func assertSuccess(
        _ phase: RemoteImageLoader.Phase,
        expectedImage: UIImage? = nil,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        guard case .success(let image) = phase else {
            return XCTFail("Expected success phase", file: file, line: line)
        }
        if let expectedImage {
            XCTAssertTrue(image === expectedImage, file: file, line: line)
        }
    }

    private func makeImage(color: UIColor) -> UIImage {
        UIGraphicsImageRenderer(size: CGSize(width: 10, height: 10)).image { context in
            color.setFill()
            context.fill(CGRect(x: 0, y: 0, width: 10, height: 10))
        }
    }
}

private enum TestError: Error {
    case unexpectedRequest
}

private final class ImageCacheStub: ImageCache {
    private var images: [URL: UIImage] = [:]

    subscript(_ url: URL) -> UIImage? {
        get { images[url] }
        set { images[url] = newValue }
    }
}

private actor RemoteImageDataLoaderStub: RemoteImageDataLoading {
    private let result: Result<(Data, URLResponse), Error>
    private(set) var requestCount = 0

    init(result: Result<(Data, URLResponse), Error>) {
        self.result = result
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        requestCount += 1
        return try result.get()
    }
}

private actor ControlledRemoteImageDataLoader: RemoteImageDataLoading {
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

    func succeed(url: URL, data: Data) {
        let response = HTTPURLResponse(
            url: url,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!
        continuations.removeValue(forKey: url)?.resume(returning: (data, response))
    }
}
