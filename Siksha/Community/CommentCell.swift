//
//  CommentCell.swift
//  Siksha
//
//  Created by 박정헌 on 2023/08/26.
//

import Foundation
import SwiftUI

struct CommentCell<ViewModel>: View where ViewModel: CommunityPostViewModel {
    var comment:CommentInfo
    var viewModel: ViewModel
    
    @State private var showingDeleteAlert = false
    @State private var reportAlertIsShown = false
    private var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: comment.createdAt, relativeTo: Date())
    }
    
    @State private var showingEditView = false
    @State private var editedContent: String
    
    init(comment: CommentInfo, viewModel: ViewModel) {
        self.comment = comment
        self.viewModel = viewModel
        _editedContent = State(initialValue: comment.content)
    }
    
    var body:some View{
        VStack(alignment:.leading,spacing:0){
            HStack(spacing:0) {
                Text("\(comment.nickname)")
                    .font(.custom("Inter-Regular",size:10))
                    .foregroundColor(.init("ReviewMediumColor"))
                
                Spacer()
                                
                Text(relativeDate)
                    .font(.custom("Inter-Regular", size: 8))
                    .frame(width:50, alignment: .trailing)
                    .foregroundColor(.init("ReviewLowColor"))
            }
            Spacer()
                .frame(height:8)
            Text(comment.content)
                .font(.custom("Inter-Regular", size: 12))
                .foregroundColor(.init("ReviewHighColor"))
                
            Spacer()
                .frame(height:12)
            HStack(spacing:0){
                Button(action: {
                    viewModel.toggleCommentLike(id: comment.id)
                }) {
                    Image(comment.isLiked ? "PostLike-liked" : "PostLike-default")
                        .frame(width: 11.5, height: 11)
                        .padding(.init(top: 0, leading: 0, bottom: 4, trailing: 0))
                }
                Spacer()
                    .frame(width:4)
                Text("\(comment.likeCnt)")
                    .font(.custom("Inter-Regular", size: 8))
                    .foregroundColor(.init("MainThemeColor"))
                Spacer()
                
                Menu{
                    if (comment.isMine) {
                        Button("수정", action: {
                            self.showingEditView = true
                        })
                        Button("삭제", action: {
                            self.showingDeleteAlert = true
                        })
                    }
                    if(!comment.isMine){
                        Button("신고하기", action: {
                            reportAlertIsShown = true
                        })
                    }
                    Button("취소", action: {})
                }
                
                
            label:{
                    Image("etc")
                        .frame(width:13,height:1.86)
                      
                }
            }
        }
        .padding(EdgeInsets(top: 12, leading: 35, bottom: 12, trailing: 35))
        .fullScreenCover(isPresented: $showingEditView) {
            EditCommentView(isPresented: $showingEditView, editedContent: comment.content, onSave: { newContent in
                            viewModel.editComment(commentId: comment.id, content: newContent)
                            showingEditView = false
                        }, onCancel: {
                            showingEditView = false
                        })
        }
        .alert(isPresented: $showingDeleteAlert) {
                    Alert(
                        title: Text(""),
                        message: Text("이 댓글을 삭제하시겠습니까?"),
                        primaryButton: .default(Text("확인")) {
                            viewModel.deleteComment(id: comment.id)
                        },
                        secondaryButton: .cancel()
                    )
                }
        .textFieldAlert(isPresented: $reportAlertIsShown, title: "신고 사유", action: {reason in
            viewModel.reportComment(commentId: comment.id, reason: reason ?? "")
        
        })
   
    }
    
}

struct EditCommentView: View {
    @Binding var isPresented: Bool
    @State var editedContent: String
    let onSave: (String) -> Void
    let onCancel: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottom) {
                Color("MainThemeColor")
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
                .background(Color("MainThemeColor").opacity(0))
            }
            .frame(height: 40)

            TextField("수정할 내용", text: $editedContent)
                .textFieldStyle(PlainTextFieldStyle())
                .padding()
            
            Spacer()
        }
    }
}

/*struct CommentCell_preview:PreviewProvider{
    static var previews: some View{
        CommentCell(comment: CommentInfo(content: "test1", likeCnt: 1, isLiked: true),
                    viewModel: StubCommunityPostViewModel())
    }
}*/

