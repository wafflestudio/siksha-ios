//
//  KeywordReivewView.swift
//  Siksha
//
//  Created by Jihyeon on 9/14/25.
//

import SwiftUI
import Kingfisher

struct KeywordReivewView: View {
    var body: some View {
        Text("KeywordReivewView")
    }
}

struct ReviewRow: View {
    let showImage: Bool
    
    @State var isLiked: Bool = true
    @State var isImageExpanded: Bool = false
    @State var tappedIndex: Int = 0
    
    private let tempImages = [
        URL(string: "https://images.unsplash.com/photo-1574158622682-e40e69881006?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1480")!,
        URL(string: "https://images.unsplash.com/photo-1519052537078-e6302a4968d4?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1470")!,
        URL(string: "https://images.unsplash.com/photo-1580784355703-37c3f6c29052?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1374")!,
        URL(string: "https://images.unsplash.com/photo-1655737214907-fe074d6891c0?ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&q=80&w=1449")!,
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ReviewProfileInfoView()
            
            Spacer()
                .frame(height: 4)
            
            HStack(spacing: 9.5) {
                
                ZStack(alignment: .topLeading) {
                    Text("맛있어요~!")
                        .customFont(font: .text13(weight: .Regular))
                        .foregroundStyle(Color.blackColor)
                        .padding(10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background {
                            Rectangle()
                                .fill(Color.whiteColor)
                                .cornerRadius(8)
                                .shadow(color: .blackColor.opacity(0.15), radius: 1.5)
                        }
                        .padding(.leading, 29)
                    
                    Image("SpeechArrow")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 17, height: 17)
                        .padding(.top, 7)
                        .padding(.leading, 15)
                        .foregroundStyle(Color.whiteColor)
                        .shadow(color: .blackColor.opacity(0.15), radius: 1.5)
                    
                    Text("맛있어요~!")
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
                
                Button {
                    isLiked.toggle()
                } label: {
                    VStack(spacing: 3) {
                        Image(isLiked ? "Like-on" : "Like-off")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 14, height: 14)
                            .foregroundStyle(Color.orange500)
                        Text(isLiked ? "13" : "12")
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
            
            HStack(spacing: 8) {
                keywordTag(text: "또 먹고 싶어요")
                keywordTag(text: "가성비 좋아요")
                keywordTag(text: "알찬 편이에요")
            }
            .padding(.leading, 30)
            
            if showImage {
                Spacer()
                    .frame(height: 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(Array(tempImages.enumerated()), id: \.offset) { i, url in
                            KFImage(url)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 102, height: 102)
                                .cornerRadius(8)
                                .onTapGesture {
                                    tappedIndex = i
                                    isImageExpanded = true
                                }
                        }
                    }
                }
                .padding(.leading, 30)
                .fullScreenCover(isPresented: $isImageExpanded) {
                    ImageViewer(imageURLs: tempImages, initialIndex: tappedIndex)
                }
            }
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
    let imageUrl = URL(string: "https://images.unsplash.com/photo-1579168765467-3b235f938439?q=80&w=1588&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D")!
    let nickname = "닉네임"
//    let rate
//    let writeDate
    
    var body: some View {
        HStack(alignment: .top, spacing: 7) {
            Image("BigLogoEllipse")
                .resizable()
                .scaledToFill()
                .frame(width: 32, height: 32)
                .clipShape(Circle())
                .padding(.top, 1)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(nickname)
                        .customFont(font: .text12(weight: .Bold))
                        .foregroundStyle(Color.blackColor)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    StarRateView(rate: 4, spacing: 1)
                        .frame(height: 10)
                    .padding(.bottom, 4)
                }
                
                Text("2시간 전")
                    .customFont(font: .text12(weight: .Bold))
                    .foregroundStyle(Color.gray600)
            }
        }
}

#Preview {
    ReviewRow(showImage: true)
        .padding(14)
}
