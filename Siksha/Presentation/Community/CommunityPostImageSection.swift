//
//  CommunityPostImageSection.swift
//  Siksha
//

import SwiftUI

struct CommunityPostImageSection: View {
    let attachments: [UploadImageAttachment]
    let existingImageLoadState: ExistingImageLoadState
    let remainingImageCount: Int
    let onImagesSelected: ([UIImage]) -> Void
    let onRemoveImage: (UUID) -> Void
    let onRetryExistingImages: () -> Void

    @State private var isShowingPhotoLibrary = false

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 3) {
                ForEach(attachments) { attachment in
                    imageCell(for: attachment)
                }

                stateContent
            }
        }
        .sheet(isPresented: $isShowingPhotoLibrary) {
            ImagePickerCoordinatorView(
                maxSelection: remainingImageCount,
                onImagesSelected: onImagesSelected
            )
        }
    }

    @ViewBuilder
    private var stateContent: some View {
        switch existingImageLoadState {
        case .ready:
            if remainingImageCount > 0 {
                addImageButton
            }
        case .loading:
            ProgressView()
                .frame(width: 106, height: 106)
        case .failed:
            retryButton
        }
    }

    private func imageCell(for attachment: UploadImageAttachment) -> some View {
        ZStack(alignment: .topTrailing) {
            Image(uiImage: attachment.previewImage)
                .resizable()
                .renderingMode(.original)
                .scaledToFill()
                .frame(width: 106, height: 106)
                .clipped()
                .cornerRadius(7)
                .padding(.top, 4)
                .padding(.trailing, 5)

            Button {
                onRemoveImage(attachment.id)
            } label: {
                Image("Cancel")
                    .frame(width: 18, height: 18)
                    .background(Color.white)
                    .clipShape(Circle())
            }
        }
    }

    private var addImageButton: some View {
        Button {
            isShowingPhotoLibrary = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .foregroundColor(.gray100)
                    .frame(width: 106, height: 106)

                Image(systemName: "plus")
                    .resizable()
                    .foregroundColor(.gray600)
                    .frame(width: 28, height: 28)
            }
            .padding(.top, 4)
            .padding(.trailing, 5)
        }
    }

    private var retryButton: some View {
        Button(action: onRetryExistingImages) {
            VStack(spacing: 6) {
                Image(systemName: "arrow.clockwise")
                Text("다시 시도")
                    .customFont(font: .text12(weight: .Bold))
            }
            .foregroundColor(.orange500)
            .frame(width: 106, height: 106)
            .background(Color.gray100)
            .cornerRadius(7)
            .padding(.top, 4)
            .padding(.trailing, 5)
        }
    }
}
