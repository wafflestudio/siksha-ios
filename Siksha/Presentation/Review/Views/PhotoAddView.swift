//
//  PhotoAddView.swift
//  Siksha
//
//  Created by Jihyeon on 10/19/25.
//

import SwiftUI

struct PhotoAddView: View {
    @State private var isShowingPhotoLibrary = false

    let imageAttachments: [UploadImageAttachment]
    let existingImageLoadState: ExistingImageLoadState
    let remainingImageCount: Int
    let onImagesSelected: ([UIImage]) -> Void
    let onRemoveImage: (UUID) -> Void
    let onRetryExistingImages: () -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                switch existingImageLoadState {
                case .ready:
                    if remainingImageCount > 0 {
                        Button {
                            isShowingPhotoLibrary = true
                        } label: {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(width: 80, height: 80)
                                    .foregroundStyle(Color.gray100)

                                Image(.Icons.Common.plus)
                                    .resizable()
                                    .frame(width: 21, height: 21)
                                    .foregroundStyle(Color.gray600)
                            }
                            .padding(.top, 6)
                            .padding(.trailing, 5)
                        }
                    }

                case .loading:
                    ProgressView()
                        .frame(width: 80, height: 80)

                case .failed:
                    Button(action: onRetryExistingImages) {
                        VStack(spacing: 6) {
                            Image(systemName: "arrow.clockwise")
                            Text("다시 시도")
                                .customFont(font: .text11(weight: .Bold))
                        }
                        .foregroundStyle(Color.gray700)
                        .frame(width: 80, height: 80)
                        .background(Color.gray100)
                        .cornerRadius(8)
                    }
                }

                ForEach(imageAttachments) { attachment in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: attachment.previewImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .padding(.top, 6)
                            .padding(.trailing, 5)

                        Button {
                            onRemoveImage(attachment.id)
                        } label: {
                            Image(.Icons.Common.cancelButton)
                                .frame(width: 18, height: 18)
                                .background(Color.white)
                                .clipShape(Circle())
                        }
                    }
                }
            }
        }
        .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
        .sheet(isPresented: $isShowingPhotoLibrary) {
            ImagePickerCoordinatorView(
                maxSelection: remainingImageCount,
                onImagesSelected: onImagesSelected
            )
        }
    }
}
