//
//  ImagePickerCoordinatorView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/23.
//

import SwiftUI
import Photos
import BSImagePicker

enum ImagePickerError: LocalizedError {
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

struct ImagePickerCoordinatorView {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var selectedImages: [UIImage]
    var maxSelection: Int
    var onImagesSelected: (([UIImage]) -> Void)?
    var onError: ((Error) -> Void)?
    
    private func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
        
        // Navigation Bar 배경색 세팅
        UINavigationBar.changeBackgroundColor(color: UIColor(named: "Color/Foundation/Orange/500") ?? .clear)
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
    public class Coordinator: ImagePickerControllerDelegate {
        private var parent: ImagePickerCoordinatorView
        
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

            Task { @MainActor in
                do {
                    let result = try await loadImages(from: assets)
                    if !result.images.isEmpty {
                        parent.selectedImages.append(contentsOf: result.images)
                        parent.onImagesSelected?(result.images)
                    }
                    if let error = result.error {
                        parent.onError?(error)
                    }
                } catch is CancellationError {
                    return
                }
            }
        }
        
        public func imagePicker(_ imagePicker: ImagePickerController, didCancelWithAssets assets: [PHAsset]) {
            print("Canceled with selections: \(assets)")
        }
        
        public func imagePicker(_ imagePicker: ImagePickerController, didReachSelectionLimit count: Int) {
            print("Did Reach Selection Limit: \(count)")
        }
        
        private func loadImages(from assets: [PHAsset]) async throws -> (images: [UIImage], error: Error?) {
            var images: [UIImage] = []
            var firstError: Error?
            images.reserveCapacity(assets.count)

            for asset in assets {
                try Task.checkCancellation()
                do {
                    let image = try await requestImage(for: asset)
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

            return (images, firstError)
        }

        private func requestImage(for asset: PHAsset) async throws -> UIImage {
            try await withCheckedThrowingContinuation { continuation in
                let options = PHImageRequestOptions()
                options.deliveryMode = .highQualityFormat
                options.resizeMode = .exact
                options.isNetworkAccessAllowed = true

                PHImageManager.default().requestImage(
                    for: asset,
                    targetSize: CGSize(width: 1_600, height: 1_600),
                    contentMode: .aspectFit,
                    options: options
                ) { image, info in
                    if (info?[PHImageCancelledKey] as? Bool) == true {
                        continuation.resume(throwing: CancellationError())
                    } else if let error = info?[PHImageErrorKey] as? Error {
                        continuation.resume(throwing: error)
                    } else if let image {
                        continuation.resume(returning: image)
                    } else {
                        continuation.resume(throwing: ImagePickerError.imageUnavailable)
                    }
                }
            }
        }
    }
}

//struct ImagePickerCoordinatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImagePickerCoordinatorView()
//    }
//}
