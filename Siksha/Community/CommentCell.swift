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
    var comment:CommentInfo
    var viewModel: ViewModel
    var onMenuPressed: ()->()
    @State private var showingDeleteAlert = false
    @State private var reportAlertIsShown = false
    @Binding var reportCompleteAlertIsShown: Bool
    @Binding var alertTitle: String
    @Binding var alertMessage: String
    private var relativeDate: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: comment.createdAt, relativeTo: Date())
    }
    
    @State private var showingEditView = false
    @State private var editedContent: String
    
    init(comment: CommentInfo, viewModel: ViewModel,reportCompleteAlertIsShown: Binding<Bool>, alertTitle: Binding<String>, alertMessage: Binding<String>, onMenuPressed:@escaping()->()) {
        self.comment = comment
        self.viewModel = viewModel
        self._reportCompleteAlertIsShown = reportCompleteAlertIsShown
        self._alertTitle = alertTitle
        self._alertMessage = alertMessage
        _editedContent = State(initialValue: comment.content)
        self.onMenuPressed = onMenuPressed
    }
    
    var body:some View{
        HStack{

        if(comment.available){
            VStack(alignment:.leading,spacing:0){
                HStack{
                    if let profileUrl = comment.profileUrl {
                        KFImage(URL(string:profileUrl))
                            .resizable()
                            .frame(width: 16,height:16)
                            .clipShape(Circle())
                    }
                    else{
                        Image("LogoEllipse")
                            .resizable()
                            .frame(width: 16,height:16)
                            .clipShape(Circle())
                    }
                    Spacer()
                        .frame(width:5.5)
                    Text("\(comment.nickname)")
                        .font(.custom("NanumSquareOTFB",size:11))
                        .foregroundColor(.black)
                    Spacer()
                        .frame(width:8.2)
                    Text(relativeDate)
                        .font(.custom("NanumSquareOTFR", size: 10))
                        .foregroundColor(.init("ReviewLowColor"))
                    
                }
                Spacer()
                    .frame(height:9.37)
                Text(comment.content)
                    .font(.custom("NanumSquareOTFR", size: 12))
                    .foregroundColor(.init("ReviewHighColor"))
                
                
                Image("etc")
                    .frame(width:16,height:2.29)
                    .padding(EdgeInsets(top: 15, leading: 2.25, bottom: 15, trailing: 0))
                    .onTapGesture {
                        onMenuPressed()
                    }
                
                
                
            }
            Spacer()
            
            Button(action: {
                viewModel.toggleCommentLike(id: comment.id)
            }) {
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: 10)
                    VStack(spacing: 8) {
                        Image(comment.isLiked ? "PostLike-liked" : "PostLike-default")
                            .frame(width: 11.5, height: 11)
                            .padding(.init(top: 0, leading: 0, bottom: 4, trailing: 0))
                        Text("\(comment.likeCnt)")
                            .font(.custom("Inter-Regular", size: 8))
                            .foregroundColor(.init("MainThemeColor"))
                    }
                    .padding(EdgeInsets(top: 12.5, leading: 11, bottom: 12.5, trailing: 11))
                    .background(Color("CommentLikeBackgroundColor"))
                    .cornerRadius(6)
                    Spacer()
                        .frame(height: 10)
                }
            }
            .buttonStyle(PlainButtonStyle())

            
        }
            else{
                Text("신고가 누적되어 숨겨진 댓글입니다.")
                    .font(.custom("NanumSquareOTFR", size: 12))
                    .foregroundColor(Color(hex: 0xB7B7B7))
                    .frame(maxWidth: .infinity,alignment:.leading)
                    .padding(EdgeInsets(top: 17.55
                                        , leading: 0, bottom: 27.5
, trailing: 0))
            }
    }
   
    
        .padding(EdgeInsets(top: 9.95, leading: 22, bottom: 0, trailing: 18.67))
        .fullScreenCover(isPresented: $showingEditView) {
            EditCommentView(isPresented: $showingEditView, editedContent: comment.content, onSave: { newContent in
                viewModel.editComment(commentId: comment.id, content: newContent)
                showingEditView = false
            }, onCancel: {
                showingEditView = false
            })
        }
      
        .textFieldAlert(isPresented: $reportAlertIsShown, title: "신고 사유", action: {reason in
            viewModel.reportComment(commentId: comment.id, reason: reason ?? "") {
                success, errorMessage in
                if success {
                    alertTitle = "신고"
                    alertMessage = "신고되었습니다."
                } else {
                    alertTitle = "신고"
                    alertMessage = errorMessage ?? "신고에 실패했습니다."
                }
                
                reportAlertIsShown = false
                reportCompleteAlertIsShown = true
            }
            
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

