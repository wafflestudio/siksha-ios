//
//  UploadImageAttachment.swift
//  Siksha
//

import Foundation
import UIKit

struct UploadImageAttachment: Identifiable {
    enum Origin: Equatable {
        case downloaded
        case selected
    }

    let id: UUID
    let previewImage: UIImage
    let uploadData: Data
    let origin: Origin
}

enum ExistingImageLoadState: Equatable {
    case ready
    case loading
    case failed
}

enum UploadImagePreparationError: Error {
    case invalidImageData
    case jpegEncodingFailed
}

@MainActor
protocol UploadImagePreparing {
    func prepareDownloadedImage(data: Data) throws -> UploadImageAttachment
    func prepareSelectedImage(_ image: UIImage) throws -> UploadImageAttachment
}

struct JPEGUploadImagePreparer: UploadImagePreparing {
    private let compressionQuality: CGFloat

    init(compressionQuality: CGFloat = 0.5) {
        self.compressionQuality = compressionQuality
    }

    func prepareDownloadedImage(data: Data) throws -> UploadImageAttachment {
        guard let previewImage = UIImage(data: data) else {
            throw UploadImagePreparationError.invalidImageData
        }

        return UploadImageAttachment(
            id: UUID(),
            previewImage: previewImage,
            uploadData: data,
            origin: .downloaded
        )
    }

    func prepareSelectedImage(_ image: UIImage) throws -> UploadImageAttachment {
        guard let data = image.jpegData(compressionQuality: compressionQuality) else {
            throw UploadImagePreparationError.jpegEncodingFailed
        }
        guard let previewImage = UIImage(data: data) else {
            throw UploadImagePreparationError.invalidImageData
        }

        return UploadImageAttachment(
            id: UUID(),
            previewImage: previewImage,
            uploadData: data,
            origin: .selected
        )
    }
}
