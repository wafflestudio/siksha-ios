//
//  ImagePickerCoordinatorView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/23.
//

import BSImagePicker
import Photos
import SwiftUI
import os

enum ImagePickerError: LocalizedError, Sendable {
    case imageUnavailable
    case imageProcessingFailed

    var errorDescription: String? {
        switch self {
        case .imageUnavailable:
            return "선택한 사진을 불러올 수 없습니다. 네트워크 연결을 확인한 후 다시 시도해 주세요."
        case .imageProcessingFailed:
            return "선택한 사진을 처리할 수 없습니다. 다른 사진을 선택해 주세요."
        }
    }
}

enum PhotoImageRequestResult: Sendable {
    case success(Data)
    case failure(ImagePickerError)
    case cancelled
}

protocol PhotoImageRequesting: Sendable {
    func requestImageData(
        for asset: PHAsset,
        completion: @escaping @Sendable (PhotoImageRequestResult) -> Void
    ) -> PHImageRequestID
    func cancelImageRequest(_ requestID: PHImageRequestID)
}

struct PhotoKitImageRequester: PhotoImageRequesting {
    private let manager: PHImageManager

    init(manager: PHImageManager = .default()) {
        self.manager = manager
    }

    func requestImageData(
        for asset: PHAsset,
        completion: @escaping @Sendable (PhotoImageRequestResult) -> Void
    ) -> PHImageRequestID {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true

        return manager.requestImageDataAndOrientation(for: asset, options: options) { data, _, _, info in
            if (info?[PHImageCancelledKey] as? Bool) == true {
                completion(.cancelled)
            } else if info?[PHImageErrorKey] as? Error != nil {
                completion(.failure(.imageUnavailable))
            } else if let data {
                completion(.success(data))
            } else {
                completion(.failure(.imageUnavailable))
            }
        }
    }

    func cancelImageRequest(_ requestID: PHImageRequestID) {
        manager.cancelImageRequest(requestID)
    }
}

protocol PhotoImageDataLoading: Sendable {
    func loadImageData(for asset: PHAsset) async throws -> Data
}

struct PhotoKitImageDataLoader: PhotoImageDataLoading {
    private let requester: PhotoImageRequesting

    init(requester: PhotoImageRequesting = PhotoKitImageRequester()) {
        self.requester = requester
    }

    func loadImageData(for asset: PHAsset) async throws -> Data {
        let state = PhotoImageRequestState()

        return try await withTaskCancellationHandler {
            try await withCheckedThrowingContinuation { continuation in
                guard state.install(continuation) else { return }

                let requestID = requester.requestImageData(for: asset) { result in
                    state.complete(result)
                }
                if state.store(requestID: requestID) {
                    requester.cancelImageRequest(requestID)
                }
            }
        } onCancel: {
            if let requestID = state.cancel() {
                requester.cancelImageRequest(requestID)
            }
        }
    }
}

private final class PhotoImageRequestState: Sendable {
    private struct State: Sendable {
        var continuation: CheckedContinuation<Data, Error>?
        var requestID = PHInvalidImageRequestID
        var result: PhotoImageRequestResult?
    }

    private enum Installation: Sendable {
        case start
        case complete(PhotoImageRequestResult)
    }

    private let lock = OSAllocatedUnfairLock(initialState: State())

    func install(_ continuation: CheckedContinuation<Data, Error>) -> Bool {
        let installation = lock.withLock { state -> Installation in
            if let result = state.result {
                return .complete(result)
            }
            state.continuation = continuation
            return .start
        }

        switch installation {
        case .start:
            return true
        case .complete(let result):
            resume(continuation, with: result)
            return false
        }
    }

    func store(requestID: PHImageRequestID) -> Bool {
        lock.withLock { state in
            state.requestID = requestID
            if case .cancelled? = state.result {
                return true
            }
            return false
        }
    }

    func complete(_ result: PhotoImageRequestResult) {
        let continuation = lock.withLock { state -> CheckedContinuation<Data, Error>? in
            guard state.result == nil else { return nil }
            state.result = result
            defer { state.continuation = nil }
            return state.continuation
        }
        if let continuation {
            resume(continuation, with: result)
        }
    }

    func cancel() -> PHImageRequestID? {
        let cancellation = lock.withLock { state -> (CheckedContinuation<Data, Error>?, PHImageRequestID?) in
            guard state.result == nil else { return (nil, nil) }
            state.result = .cancelled
            defer { state.continuation = nil }
            let requestID = state.requestID == PHInvalidImageRequestID ? nil : state.requestID
            return (state.continuation, requestID)
        }
        cancellation.0?.resume(throwing: CancellationError())
        return cancellation.1
    }

    private func resume(
        _ continuation: CheckedContinuation<Data, Error>,
        with result: PhotoImageRequestResult
    ) {
        switch result {
        case .success(let data):
            continuation.resume(returning: data)
        case .failure(let error):
            continuation.resume(throwing: error)
        case .cancelled:
            continuation.resume(throwing: CancellationError())
        }
    }
}

struct ImagePickerCoordinatorView {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    let maxSelection: Int
    private let selectionHandler: ([UIImage]) -> Void
    private let errorHandler: ((Error) -> Void)?
    private let photoImageDataLoader: PhotoImageDataLoading

    init(
        selectedImages: Binding<[UIImage]>,
        maxSelection: Int,
        onImagesSelected: (([UIImage]) -> Void)? = nil,
        onError: ((Error) -> Void)? = nil,
        photoImageDataLoader: PhotoImageDataLoading = PhotoKitImageDataLoader()
    ) {
        self.maxSelection = maxSelection
        self.selectionHandler = { images in
            selectedImages.wrappedValue.append(contentsOf: images)
            onImagesSelected?(images)
        }
        self.errorHandler = onError
        self.photoImageDataLoader = photoImageDataLoader
    }

    init(
        maxSelection: Int,
        onImagesSelected: @escaping ([UIImage]) -> Void,
        onError: ((Error) -> Void)? = nil,
        photoImageDataLoader: PhotoImageDataLoading = PhotoKitImageDataLoader()
    ) {
        self.maxSelection = maxSelection
        self.selectionHandler = onImagesSelected
        self.errorHandler = onError
        self.photoImageDataLoader = photoImageDataLoader
    }

    private func handleSelectedImages(_ images: [UIImage]) {
        selectionHandler(images)
    }

    private func handleError(_ error: Error) {
        errorHandler?(error)
    }

}

extension ImagePickerCoordinatorView: UIViewControllerRepresentable {

    public typealias UIViewControllerType = ImagePickerController

    public func makeUIViewController(context: Context) -> ImagePickerController {
        let picker = ImagePickerController()
        picker.doneButtonTitle = "완료"
        picker.cancelButton.title = "취소"
        picker.imagePickerDelegate = context.coordinator
        picker.settings.selection.max = maxSelection

        UINavigationBar.changeBackgroundColor(color: .clear)

        return picker
    }

    public func updateUIViewController(_ uiViewController: ImagePickerController, context: Context) {
    }

    public func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

extension ImagePickerCoordinatorView {
    @MainActor
    public final class Coordinator: @preconcurrency ImagePickerControllerDelegate {
        // BSImagePicker 3.3.3 dispatches these UIKit delegate callbacks on the main thread.
        // Remove @preconcurrency when the dependency annotates ImagePickerControllerDelegate.
        private var parent: ImagePickerCoordinatorView
        private var imageLoadTask: Task<Void, Never>?

        public init(_ parent: ImagePickerCoordinatorView) {
            self.parent = parent
        }

        public func imagePicker(_ imagePicker: ImagePickerController, didSelectAsset asset: PHAsset) {
            print("Selected: \(asset)")
        }

        public func imagePicker(_ imagePicker: ImagePickerController, didDeselectAsset asset: PHAsset) {
            print("Deselected: \(asset)")
        }

        public func imagePicker(_ imagePicker: ImagePickerController, didFinishWithAssets assets: [PHAsset]) {
            print("Finished with selections: \(assets)")

            imageLoadTask?.cancel()
            let photoImageDataLoader = parent.photoImageDataLoader
            imageLoadTask = Task { [self] in
                do {
                    let result = try await Self.loadImages(from: assets, loader: photoImageDataLoader)
                    try Task.checkCancellation()
                    if !result.images.isEmpty {
                        parent.handleSelectedImages(result.images)
                    }
                    if let error = result.error {
                        parent.handleError(error)
                    }
                } catch is CancellationError {
                    return
                } catch {
                    parent.handleError(error)
                }
            }
        }

        public func imagePicker(_ imagePicker: ImagePickerController, didCancelWithAssets assets: [PHAsset]) {
            print("Canceled with selections: \(assets)")
            imageLoadTask?.cancel()
            imageLoadTask = nil
        }

        public func imagePicker(_ imagePicker: ImagePickerController, didReachSelectionLimit count: Int) {
            print("Did Reach Selection Limit: \(count)")
        }

        @concurrent
        private static func loadImages(
            from assets: [PHAsset],
            loader: PhotoImageDataLoading
        ) async throws -> (images: [UIImage], error: Error?) {
            var images: [UIImage] = []
            var firstError: Error?
            images.reserveCapacity(assets.count)

            for asset in assets {
                try Task.checkCancellation()
                do {
                    let data = try await loader.loadImageData(for: asset)
                    try Task.checkCancellation()
                    guard let image = UIImage(data: data) else {
                        throw ImagePickerError.imageUnavailable
                    }
                    guard let resizedImage = image.resizedToFit(maxPixelDimension: 800) else {
                        throw ImagePickerError.imageProcessingFailed
                    }
                    images.append(resizedImage)
                } catch is CancellationError {
                    throw CancellationError()
                } catch {
                    firstError = firstError ?? error
                }
            }

            try Task.checkCancellation()
            return (images, firstError)
        }
    }
}

//struct ImagePickerCoordinatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImagePickerCoordinatorView()
//    }
//}
