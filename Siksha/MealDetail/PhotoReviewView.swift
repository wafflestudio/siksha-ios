//
//  PhotoReviewView.swift
//  Siksha
//
//  Created by Jihyeon on 11/25/25.
//

import SwiftUI
import Kingfisher

struct PhotoReviewView: View {
    @ObservedObject var viewModel: MealInfoViewModel
    @State var isImageExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            titleView
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8.5) {
                    ForEach(0..<2) { i in
                        if viewModel.totalImageCount > i {
                            imageView(urlString: viewModel.images[i])
                        }
                    }
                    
                    if viewModel.totalImageCount > 2 {
                        imageView(urlString: viewModel.images[2])
                            .overlay {
                                if viewModel.totalImageCount > 3 {
                                    moreImageReviewOverlay
                                }
                            }
                    }
                }
            }
        }
    }
    
    private var moreImageReviewOverlay: some View {
        NavigationLink(destination: ReviewListView(viewModel.meal, true)) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.25))
                    .frame(width: 120, height: 120)
                
                VStack(spacing: 6) {
                    Image("Plus")
                        .renderingMode(.template)
                        .resizable()
                        .foregroundStyle(Color.white)
                        .frame(width: 10, height: 10)
                    
                    Text("\(viewModel.totalImageCount - 3)건 더보기")
                        .foregroundStyle(Color.white)
                        .customFont(font: .text12(weight: .Bold))
                }
            }
        }
    }
    
    private func imageView(urlString: String) -> some View {
        KFImage(URL(string: urlString))
            .resizable()
            .scaledToFill()
            .frame(width: 120, height: 120)
            .cornerRadius(10)
            .onTapGesture {
                isImageExpanded = true
            }
            .fullScreenCover(isPresented: $isImageExpanded) {
                ImageViewer(imageURLs: [URL(string: urlString)!], showNumber: false)
            }
    }
    
    private var titleView: some View {
        HStack(spacing: 0) {
            Text("사진 리뷰")
                .customFont(font: .text14(weight: .Bold))
                .foregroundStyle(Color.blackColor)
            Spacer()
            NavigationLink(destination: ReviewListView(Meal(), true)) {
                Image("Arrow")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 7.5, height: 12)
                    .foregroundStyle(Color.gray600)
            }
        }
    }
}

