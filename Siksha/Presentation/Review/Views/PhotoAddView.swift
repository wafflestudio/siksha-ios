//
//  PhotoAddView.swift
//  Siksha
//
//  Created by Jihyeon on 10/19/25.
//

import SwiftUI

struct PhotoAddView: View {
    @State private var isShowingPhotoLibrary = false
    @ObservedObject var viewModel: MealReviewViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                Button {
                    isShowingPhotoLibrary = true
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .frame(width: 80, height: 80)
                            .foregroundStyle(Color.gray100)

                        Image("Plus")
                            .renderingMode(.template)
                            .resizable()
                            .foregroundStyle(Color.gray600)
                            .frame(width: 21, height: 21)
                    }
                    .padding(.top, 6)
                    .padding(.trailing, 5)
                }

                ForEach(viewModel.selectedImages, id: \.self) { image in
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 80, height: 80)
                            .cornerRadius(8)
                            .padding(.top, 6)
                            .padding(.trailing, 5)

                        Button {
                            viewModel.deleteImage(image)
                        } label: {
                            Image("Cancel")
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
            ImagePickerCoordinatorView(selectedImages: $viewModel.selectedImages, maxSelection: 5)
        }
    }
}
