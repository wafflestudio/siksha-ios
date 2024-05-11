//
//  ImagePickerCoordinatorView.swift
//  Siksha
//
//  Created by You Been Lee on 2021/05/23.
//

import SwiftUI
import Photos
import BSImagePicker

struct ImagePickerCoordinatorView {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var selectedImages: [UIImage]
        
    private func dismiss() {
        self.presentationMode.wrappedValue.dismiss()
        
        // Navigation Bar 배경색 세팅
        UINavigationBar.changeBackgroundColor(color: UIColor(named: "main") ?? .clear)
    }

}

extension ImagePickerCoordinatorView: UIViewControllerRepresentable {
    
    public typealias UIViewControllerType = ImagePickerController
    
    public func makeUIViewController(context: Context) -> ImagePickerController {
        let picker = ImagePickerController()
        picker.doneButtonTitle = "완료"
        picker.cancelButton.title = "취소"
        picker.imagePickerDelegate = context.coordinator
        picker.settings.selection.max = 5
        
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
            //            parent.selectedImages = getAssetThumbnail(assets: assets)
            let newImages = getAssetThumbnail(assets: assets)
            parent.selectedImages.append(contentsOf: newImages)
            parent.dismiss()
        }
        
        public func imagePicker(_ imagePicker: ImagePickerController, didCancelWithAssets assets: [PHAsset]) {
            print("Canceled with selections: \(assets)")
            parent.dismiss()
        }
        
        public func imagePicker(_ imagePicker: ImagePickerController, didReachSelectionLimit count: Int) {
            print("Did Reach Selection Limit: \(count)")
        }
        
        func getAssetThumbnail(assets: [PHAsset]) -> [UIImage] {
            var images = [UIImage]()
            for asset in assets {
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var image = UIImage()
                option.isSynchronous = true
                manager.requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .aspectFit, options: option, resultHandler: {(result, info)->Void in
                    image = result!
                })
                image = image.resizeWithWidth(width: 800)!
                images.append(image)
            }
            return images
        }
    }
}

//struct ImagePickerCoordinatorView_Previews: PreviewProvider {
//    static var previews: some View {
//        ImagePickerCoordinatorView()
//    }
//}
