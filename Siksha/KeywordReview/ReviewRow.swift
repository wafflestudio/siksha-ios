//
//  ReviewRow.swift
//  Siksha
//
//  Created by Jihyeon on 9/14/25.
//

import SwiftUI
import Kingfisher

struct ReviewRow: View {
    @StateObject var viewModel: ReviewRowViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ReviewProfileInfoView(viewModel: viewModel)
            
            Spacer().frame(height: 4)
            
            HStack(spacing: 9.5) {
                if viewModel.hasComment {
                    ZStack(alignment: .topLeading) {
                        Image("SpeechArrow")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 17, height: 17)
                            .padding(.top, 7)
                            .padding(.leading, 15)
                            .foregroundStyle(Color.whiteColor)
                        
                        Text(viewModel.comment)
                            .customFont(font: .text13(weight: .Regular))
                            .foregroundStyle(Color.blackColor)
                            .padding(10)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background {
                                Rectangle()
                                    .fill(Color.whiteColor)
                                    .cornerRadius(8)
                            }
                            .padding(.leading, 29)
                    }
                    .drawingGroup()
                    .shadow(color: .blackColor.opacity(0.15), radius: 1.5)
                }
                
                Button {
                    viewModel.toggleLike()
                } label: {
                    VStack(spacing: 3) {
                        Image(viewModel.isLiked ? "Like-on" : "Like-off")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(Color.orange500)
                        Text("\(viewModel.likeCount)")
                            .customFont(font: .text9(weight: .ExtraBold))
                            .foregroundStyle(Color.orange500)
                    }
                    .padding(.top, 7)
                    .padding(.bottom, 4)
                    .padding(.horizontal, 11)
                    .background {
                        Color.gray50
                    }
                    .cornerRadius(6)
                }
            }
            
            Spacer()
                .frame(height: 8)
            
            if viewModel.hasKeywords {
                HStack(spacing: 8) {
                    ForEach(viewModel.keywords, id: \.self) { keyword in
                        keywordTag(text: keyword)
                    }
                }
                .padding(.leading, 30)
            }
            
            // TODO: 이미지 보여주기!!!
//            if viewModel.showImage {
//                Spacer()
//                    .frame(height: 8)
//                
//                ScrollView(.horizontal, showsIndicators: false) {
//                    HStack(spacing: 4) {
//                        ForEach(Array(tempImages.enumerated()), id: \.offset) { i, url in
//                            KFImage(url)
//                                .resizable()
//                                .scaledToFill()
//                                .frame(width: 102, height: 102)
//                                .cornerRadius(8)
//                                .onTapGesture { tappedIndex = i }
//                        }
//                    }
//                }
//                .padding(.leading, 30)
//                .onChange(of: tappedIndex) { index in
//                    isImageExpanded = true
//                }
//                .fullScreenCover(isPresented: $isImageExpanded) {
//                    ImageViewer(imageURLs: tempImages, initialIndex: tappedIndex)
//                }
//            }
        }
    }
}

struct keywordTag: View {
    let text: String
    
    var body: some View {
        Text(text)
            .customFont(font: .text11(weight: .Bold))
            .foregroundStyle(Color.gray700)
            .padding(4)
            .background {
                Color.elementChip
            }
            .cornerRadius(4)
    }
}

struct ReviewProfileInfoView: View {
    let viewModel: ReviewRowViewModel
    
    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image("BigLogoEllipse")
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .padding(.top, 1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(viewModel.nickname)
                        .customFont(font: .text12(weight: .Bold))
                        .foregroundStyle(Color.blackColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    StarRateView(rate: viewModel.score, spacing: 1)
                        .frame(height: 10)
                    .padding(.bottom, 4)
                }
                
            Text(viewModel.legibleDate)
                    .customFont(font: .text12(weight: .Bold))
                    .foregroundStyle(Color.gray600)
            }
        }
}
