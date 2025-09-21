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
                        .padding(.leading, 30)
                    
                    //                Image("SpeechArrow")
                    //                    .resizable()
                    //                    .scaledToFill()
                    //                    .frame(width: 17, height: 17)
                    //                    .padding(.top, 7)
                    //                    .foregroundStyle(Color.backgroundSecondary)
                }
                
                VStack(spacing: 3) {
                    Image("Like-on")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 13.5, height: 13)
                        .foregroundStyle(Color.orange500)
                    Text("12")
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
            
            Spacer()
                .frame(height: 8)
            
            HStack(spacing: 8) {
                ForEach(0..<3) { _ in
                    keywordTag()
                }
            }
            .padding(.leading, 30)
        }
    }
}

struct keywordTag: View {
    var body: some View {
        Text("또 먹고 싶어요")
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
                KFImage(imageUrl)
                    .placeholder {
                        Image("LogoEllipse")
                            .resizable()
                            .scaledToFit()
                    }
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
                    
                    HStack(spacing: 1.5) {
                        ForEach(0..<5) { _ in
                            Image("RateStar")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .foregroundStyle(Color.orange500)
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.bottom, 4)
                }
                
                Text("2시간 전")
                    .customFont(font: .text12(weight: .Bold))
                    .foregroundStyle(Color.gray600)
            }
        }
}

#Preview {
    ReviewRow()
        .padding(14)
}
