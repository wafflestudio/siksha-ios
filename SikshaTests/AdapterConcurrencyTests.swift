//
//  AdapterConcurrencyTests.swift
//  SikshaTests
//

import BSImagePicker
import Photos
import SwiftUI
import UIKit
import WebKit
import XCTest
import os

@testable import Siksha

@MainActor
final class AdapterConcurrencyTests: XCTestCase {
    func testPhotoImageDataLoaderCancelsUnderlyingRequestAndIgnoresLateCallback() async throws {
        let requester = PhotoImageRequesterStub()
        let loader = PhotoKitImageDataLoader(requester: requester)
        let task = Task {
            try await loader.loadImageData(for: PHAsset())
        }
        try await requester.waitForRequestCount(1)
        let requestID = try XCTUnwrap(requester.requestIDs.first)

        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected cancellation")
        } catch is CancellationError {
        } catch {
            XCTFail("Expected CancellationError, got \(error)")
        }

        XCTAssertEqual(requester.cancelledRequestIDs, [requestID])
        requester.completeRequest(requestID, with: .success(Data([0x01])))
    }

    func testPhotoImageDataLoaderResumesOnlyOnce() async throws {
        let requester = PhotoImageRequesterStub()
        let loader = PhotoKitImageDataLoader(requester: requester)
        let task = Task {
            try await loader.loadImageData(for: PHAsset())
        }
        try await requester.waitForRequestCount(1)
        let requestID = try XCTUnwrap(requester.requestIDs.first)

        requester.completeRequest(requestID, with: .success(Data([0x01])))
        let data = try await task.value
        XCTAssertEqual(data, Data([0x01]))

        requester.completeRequest(requestID, with: .failure(ImagePickerError.imageUnavailable))
    }

    func testImagePickerPreservesOrderAndReportsPartialFailure() async throws {
        let loader = ControlledPhotoImageDataLoader()
        let images = AdapterValueBox<[UIImage]>([])
        let errors = AdapterValueBox<[Error]>([])
        let parent = ImagePickerCoordinatorView(
            maxSelection: 2,
            onImagesSelected: { images.value = $0 },
            onError: { errors.value.append($0) },
            photoImageDataLoader: loader
        )
        let coordinator = ImagePickerCoordinatorView.Coordinator(parent)
        let picker = ImagePickerController()

        coordinator.imagePicker(picker, didFinishWithAssets: [PHAsset(), PHAsset()])
        try await loader.waitForRequestCount(1)
        await loader.completeRequest(at: 0, with: .success(try imageData(width: 10)))
        try await loader.waitForRequestCount(2)
        await loader.completeRequest(at: 1, with: .failure(ImagePickerError.imageUnavailable))
        try await waitUntil { images.value.count == 1 && errors.value.count == 1 }

        XCTAssertEqual(images.value.map(\.size.width), [10])
        XCTAssertTrue(errors.value[0] is ImagePickerError)
    }

    func testLatestImagePickerSelectionWins() async throws {
        let loader = ControlledPhotoImageDataLoader()
        let selections = AdapterValueBox<[[UIImage]]>([])
        let parent = ImagePickerCoordinatorView(
            maxSelection: 1,
            onImagesSelected: { selections.value.append($0) },
            onError: { _ in },
            photoImageDataLoader: loader
        )
        let coordinator = ImagePickerCoordinatorView.Coordinator(parent)
        let picker = ImagePickerController()

        coordinator.imagePicker(picker, didFinishWithAssets: [PHAsset()])
        try await loader.waitForRequestCount(1)
        coordinator.imagePicker(picker, didFinishWithAssets: [PHAsset()])
        try await loader.waitForRequestCount(2)

        await loader.completeRequest(at: 1, with: .success(try imageData(width: 20)))
        try await waitUntil { selections.value.count == 1 }
        await loader.completeRequest(at: 0, with: .success(try imageData(width: 5)))
        for _ in 0..<10 {
            await Task.yield()
        }

        XCTAssertEqual(selections.value.count, 1)
        XCTAssertEqual(selections.value[0].map(\.size.width), [20])
    }

    func testCompletedImagePickerSelectionOutlivesCoordinator() async throws {
        let loader = ControlledPhotoImageDataLoader()
        let images = AdapterValueBox<[UIImage]>([])
        let parent = ImagePickerCoordinatorView(
            maxSelection: 1,
            onImagesSelected: { images.value = $0 },
            photoImageDataLoader: loader
        )
        var coordinator: ImagePickerCoordinatorView.Coordinator? = .init(parent)
        let picker = ImagePickerController()

        coordinator?.imagePicker(picker, didFinishWithAssets: [PHAsset()])
        try await loader.waitForRequestCount(1)
        coordinator = nil
        await loader.completeRequest(at: 0, with: .success(try imageData(width: 15)))
        try await waitUntil { images.value.count == 1 }

        XCTAssertEqual(images.value.map(\.size.width), [15])
        withExtendedLifetime(picker) {}
    }

    func testKakaoLoginCallbackSharesAndDismissesOnTokenSuccess() throws {
        let manager = KakaoShareManagerStub()
        let presentation = AdapterValueBox(true)
        let delegate = KakaoShareNavigationDelegate(
            showWebView: Binding(
                get: { presentation.value },
                set: { presentation.value = $0 }
            ),
            restaurant: KakaoShareRestaurantModel(nameKr: "Restaurant", menus: []),
            selectedDate: "2026-07-23",
            kakaoShareManager: manager
        )
        let callbackURL = try XCTUnwrap(URL(string: "https://siksha.example/login?code=authorization-code"))

        XCTAssertEqual(delegate.decidePolicy(for: callbackURL), .allow)
        XCTAssertEqual(manager.receivedAuthorizationCode, "authorization-code")
        XCTAssertTrue(presentation.value)

        manager.completeTokenExchange(succeeded: true)

        XCTAssertEqual(manager.shareCallCount, 1)
        XCTAssertFalse(presentation.value)
    }

    func testKakaoLoginCallbackDoesNotDismissOnTokenFailure() throws {
        let manager = KakaoShareManagerStub()
        let presentation = AdapterValueBox(true)
        let delegate = KakaoShareNavigationDelegate(
            showWebView: Binding(
                get: { presentation.value },
                set: { presentation.value = $0 }
            ),
            restaurant: KakaoShareRestaurantModel(nameKr: "Restaurant", menus: []),
            selectedDate: "2026-07-23",
            kakaoShareManager: manager
        )
        let callbackURL = try XCTUnwrap(URL(string: "https://siksha.example/login?code=authorization-code"))

        XCTAssertEqual(delegate.decidePolicy(for: callbackURL), .allow)
        manager.completeTokenExchange(succeeded: false)

        XCTAssertEqual(manager.shareCallCount, 0)
        XCTAssertTrue(presentation.value)
    }

    func testKakaoWebFallbackCanPresentReplacementURLAfterAuthentication() throws {
        let manager = KakaoShareManagerStub()
        let presentation = AdapterValueBox(true)
        manager.onShare = {
            manager.webViewLoadRevision += 1
            presentation.value = true
        }
        let delegate = KakaoShareNavigationDelegate(
            showWebView: Binding(
                get: { presentation.value },
                set: { presentation.value = $0 }
            ),
            restaurant: KakaoShareRestaurantModel(nameKr: "Restaurant", menus: []),
            selectedDate: "2026-07-23",
            kakaoShareManager: manager
        )
        let callbackURL = try XCTUnwrap(URL(string: "https://siksha.example/login?code=authorization-code"))

        _ = delegate.decidePolicy(for: callbackURL)
        manager.completeTokenExchange(succeeded: true)

        XCTAssertEqual(manager.shareCallCount, 1)
        XCTAssertTrue(presentation.value)
        XCTAssertEqual(manager.webViewLoadRevision, 1)
    }

    func testWebViewCoordinatorRetainsInjectedNavigationDelegate() {
        let manager = KakaoShareManagerStub()
        let presentation = AdapterValueBox(true)
        var delegate: KakaoShareNavigationDelegate? = KakaoShareNavigationDelegate(
            showWebView: Binding(
                get: { presentation.value },
                set: { presentation.value = $0 }
            ),
            restaurant: KakaoShareRestaurantModel(nameKr: "Restaurant", menus: []),
            selectedDate: "2026-07-23",
            kakaoShareManager: manager
        )
        let webView = WebView(
            urlString: "https://siksha.example",
            showWebView: .constant(true),
            navigationDelegate: delegate
        )
        let coordinator = WebView.Coordinator(webView)

        delegate = nil

        XCTAssertNotNil(coordinator.navigationDelegate)
        withExtendedLifetime(coordinator) {}
    }

    func testWebViewLoadsOnlyChangedInputURLs() {
        let webView = WebView(
            urlString: "https://siksha.example/first",
            showWebView: .constant(true)
        )
        let coordinator = WebView.Coordinator(webView)
        let webViewSpy = WebViewSpy()

        coordinator.loadURLIfNeeded("https://siksha.example/first", in: webViewSpy)
        coordinator.loadURLIfNeeded("https://siksha.example/first", in: webViewSpy)
        coordinator.loadURLIfNeeded("https://siksha.example/second", in: webViewSpy)

        XCTAssertEqual(
            webViewSpy.loadedURLs,
            [
                URL(string: "https://siksha.example/first"),
                URL(string: "https://siksha.example/second"),
            ]
        )
    }

    func testInteractivePopGestureDelegateRequiresPushedViewController() {
        let root = UIViewController()
        let navigationController = UINavigationController(rootViewController: root)
        let delegate = InteractivePopGestureDelegate()
        delegate.navigationController = navigationController

        XCTAssertFalse(delegate.gestureRecognizerShouldBegin(UIPanGestureRecognizer()))

        navigationController.pushViewController(UIViewController(), animated: false)

        XCTAssertTrue(delegate.gestureRecognizerShouldBegin(UIPanGestureRecognizer()))
    }

    func testInteractivePopGestureBridgeRestoresPreviousDelegate() throws {
        let root = UIViewController()
        let navigationController = UINavigationController(rootViewController: root)
        navigationController.loadViewIfNeeded()
        let gestureRecognizer = try XCTUnwrap(navigationController.interactivePopGestureRecognizer)
        let previousDelegate = GestureRecognizerDelegateStub()
        gestureRecognizer.delegate = previousDelegate
        let controller = InteractivePopGestureBridgeController()
        root.addChild(controller)
        root.view.addSubview(controller.view)
        controller.didMove(toParent: root)

        controller.install()

        XCTAssertTrue(gestureRecognizer.delegate is InteractivePopGestureDelegate)

        controller.uninstall()

        XCTAssertTrue(gestureRecognizer.delegate === previousDelegate)
    }

    func testNestedInteractivePopGestureBridgeDoesNotReplaceOwner() throws {
        let root = UIViewController()
        let navigationController = UINavigationController(rootViewController: root)
        navigationController.loadViewIfNeeded()
        let gestureRecognizer = try XCTUnwrap(navigationController.interactivePopGestureRecognizer)
        let previousDelegate = GestureRecognizerDelegateStub()
        gestureRecognizer.delegate = previousDelegate
        let firstController = InteractivePopGestureBridgeController()
        let secondController = InteractivePopGestureBridgeController()
        for controller in [firstController, secondController] {
            root.addChild(controller)
            root.view.addSubview(controller.view)
            controller.didMove(toParent: root)
        }

        firstController.install()
        let owner = gestureRecognizer.delegate
        secondController.install()

        XCTAssertTrue(gestureRecognizer.delegate === owner)

        secondController.uninstall()
        XCTAssertTrue(gestureRecognizer.delegate === owner)

        firstController.uninstall()
        XCTAssertTrue(gestureRecognizer.delegate === previousDelegate)
    }

    private func imageData(width: CGFloat) throws -> Data {
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let image = UIGraphicsImageRenderer(
            size: CGSize(width: width, height: 5),
            format: format
        ).image { context in
            UIColor.orange.setFill()
            context.fill(CGRect(x: 0, y: 0, width: width, height: 5))
        }
        return try XCTUnwrap(image.pngData())
    }

    private func waitUntil(_ condition: @escaping @MainActor () -> Bool) async throws {
        for _ in 0..<1_000 {
            if condition() {
                return
            }
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        throw AdapterTestError.timedOut
    }
}

private struct PhotoImageRequesterStub: PhotoImageRequesting, Sendable {
    private struct State: Sendable {
        var nextRequestID: PHImageRequestID = 1
        var completions: [PHImageRequestID: @Sendable (PhotoImageRequestResult) -> Void] = [:]
        var cancelledRequestIDs: [PHImageRequestID] = []
    }

    private let state = OSAllocatedUnfairLock(initialState: State())

    var requestIDs: [PHImageRequestID] {
        state.withLock { $0.completions.keys.sorted() }
    }

    var cancelledRequestIDs: [PHImageRequestID] {
        state.withLock { $0.cancelledRequestIDs }
    }

    func requestImageData(
        for asset: PHAsset,
        completion: @escaping @Sendable (PhotoImageRequestResult) -> Void
    ) -> PHImageRequestID {
        state.withLock { state in
            let requestID = state.nextRequestID
            state.nextRequestID += 1
            state.completions[requestID] = completion
            return requestID
        }
    }

    func cancelImageRequest(_ requestID: PHImageRequestID) {
        state.withLock { $0.cancelledRequestIDs.append(requestID) }
    }

    func completeRequest(_ requestID: PHImageRequestID, with result: PhotoImageRequestResult) {
        let completion = state.withLock { $0.completions[requestID] }
        completion?(result)
    }

    func waitForRequestCount(_ count: Int) async throws {
        for _ in 0..<1_000 {
            if requestIDs.count >= count {
                return
            }
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        throw AdapterTestError.timedOut
    }
}

private actor ControlledPhotoImageDataLoader: PhotoImageDataLoading {
    private var continuations: [CheckedContinuation<Data, Error>] = []

    func loadImageData(for asset: PHAsset) async throws -> Data {
        try await withCheckedThrowingContinuation { continuation in
            continuations.append(continuation)
        }
    }

    func waitForRequestCount(_ count: Int) async throws {
        for _ in 0..<1_000 {
            if continuations.count >= count {
                return
            }
            try await Task.sleep(nanoseconds: 1_000_000)
        }
        throw AdapterTestError.timedOut
    }

    func completeRequest(at index: Int, with result: Result<Data, Error>) {
        continuations[index].resume(with: result)
    }
}

@MainActor
private final class KakaoShareManagerStub: KakaoShareManaging {
    private var tokenCompletion: (@MainActor @Sendable (Bool) -> Void)?
    var webViewLoadRevision = 0
    var receivedAuthorizationCode: String?
    var shareCallCount = 0
    var onShare: (() -> Void)?

    func isKakaoTalkLoginURL(_ url: URL) -> Bool {
        true
    }

    func exchangeToken(
        code: String,
        completion: @escaping @MainActor @Sendable (Bool) -> Void
    ) {
        receivedAuthorizationCode = code
        tokenCompletion = completion
    }

    func shareKakao(restaurant: KakaoShareRestaurantModel, selectedDateString: String) {
        shareCallCount += 1
        onShare?()
    }

    func completeTokenExchange(succeeded: Bool) {
        tokenCompletion?(succeeded)
    }
}

private final class GestureRecognizerDelegateStub: NSObject, UIGestureRecognizerDelegate {}

@MainActor
private final class WebViewSpy: WKWebView {
    var loadedURLs: [URL?] = []

    override func load(_ request: URLRequest) -> WKNavigation? {
        loadedURLs.append(request.url)
        return nil
    }
}

private enum AdapterTestError: Error {
    case timedOut
}

@MainActor
private final class AdapterValueBox<Value> {
    var value: Value

    init(_ value: Value) {
        self.value = value
    }
}
