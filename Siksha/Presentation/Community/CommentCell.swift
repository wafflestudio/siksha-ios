//
//  CommentCell.swift
//  Siksha
//
//  Created by 박정헌 on 2023/08/26.
//

import Foundation
import SwiftUI

import Kingfisher

struct CommentCell<ViewModel>: View where ViewModel: CommunityPostViewModelType {
    var comment: CommentInfo
    var viewModel: ViewModel
    var onMenuPressed: () -> ()
    
    private var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: comment.createdAt, relativeTo: Date())
    }
    
    @State private var showingDeleteAlert = false
    @State private var showingEditView = false
    @State private var editedContent: String
    
    init(comment: CommentInfo, viewModel: ViewModel,onMenuPressed:@escaping()->()) {
        self.comment = comment
        self.viewModel = viewModel
        _editedContent = State(initialValue: comment.content)
        self.onMenuPressed = onMenuPressed
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 11) {
            if (comment.available) {
                VStack(alignment: .leading, spacing: 5.5) {
                    HStack(spacing: 5) {
                        if let profileUrl = comment.profileUrl, !comment.isAnonymous {
                            KFImage(URL(string: profileUrl))
                                .resizable()
                                .frame(width: 20, height: 20)
                                .clipShape(Circle())
                        } else {
                            Image(.Icons.Common.profileImagePlaceholder)
                                .resizable()
                                .frame(width: 20, height: 20)
                                .clipShape(Circle())
                        }
                        Text("\(comment.nickname)")
                            .customFont(font: .text12(weight: .Bold))
                            .foregroundColor(.blackColor)
                        Text(relativeDate)
                            .customFont(font: .text12(weight: .Regular))
                            .foregroundColor(.gray600)
                    }
                    .padding(.leading, 5)
                    
                    Text(comment.content)
                        .customFont(font: .text13(weight: .Regular))
                        .foregroundStyle(Color.gray900)
                        .padding(.leading, 5)
                    
                    Image("etc")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 33, height: 23)
                        .foregroundStyle(Color.gray700)
                        .onTapGesture {
                            onMenuPressed()
                        }
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.toggleCommentLike(id: comment.id)
                }) {
                    VStack(spacing: 4) {
                        Image(comment.isLiked ? "PostLike-liked" : "PostLike-default")
                            .resizable()
                            .frame(width: 13.5, height: 13)
                            .scaledToFit()
                        Text("\(comment.likeCnt)")
                            .customFont(font: .text11(weight: .ExtraBold))
                            .foregroundColor(.orange500)
                    }
                    .padding(.vertical, 10.5)
                    .frame(width: 36)
                    .background(Color.gray50)
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.top, 8)
                
            } else {
                Text("신고가 누적되어 숨겨진 댓글입니다.")
                    .customFont(font: .text13(weight: .Regular))
                    .foregroundStyle(Color.gray900)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(EdgeInsets(top: 15, leading: 0, bottom: 25, trailing: 0))
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 6)
        .padding(.horizontal, 15)
    }
}

// TODO: 수정 필요
struct EditCommentView: View {
    @State var editedContent: String
    let onSave: (String) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Color("Color/Foundation/Orange/500")
                    .edgesIgnoringSafeArea(.top)
                
                HStack {
                    Button("취소", action: onCancel)
                        .foregroundColor(.white)
                        .font(.custom("NanumSquareOTFR", size: 15))
                    
                    Spacer()
                    
                    Text("댓글 수정")
                        .foregroundColor(.white)
                        .font(.custom("NanumSquareOTFEB", size: 20))
                    
                    Spacer()
                    
                    Button("확인", action: { onSave(editedContent) })
                        .foregroundColor(.white)
                        .font(.custom("NanumSquareOTFR", size: 15))
                }
                .padding()
                .background(Color("Color/Foundation/Orange/500").opacity(0))
            }
            .frame(height: 40)
            
            TextField("수정할 내용", text: $editedContent)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
            
            Spacer()
        }
    }
}

#Preview {
    CommentCell(comment: CommentInfo(content: "test", likeCnt: 2, isLiked: true), viewModel: StubCommunityPostViewModel(), onMenuPressed: {})
}
