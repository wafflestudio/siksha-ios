//
//  CommunityReplyBar.swift
//  Siksha
//
//  Created by 김령교 on 8/27/23.
//

import SwiftUI

struct CommunityReplyBar: View {
    @State var commentText: String = ""
    @State var isAnonymous: Bool = UserDefaults.standard.bool(forKey: "isAnonymous")
    var onCommentSubmit: (String,Bool) -> Void
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(Color.backgroundPrimary)
                .frame(height: 52)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.gray50)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 8.5)
                .overlay(
                    HStack(spacing: 0) {
                        anonymousButton
                            .padding(EdgeInsets(top: 12, leading: 12, bottom: 7, trailing: 8))
                        TextField("댓글을 입력하세요", text: $commentText)
                        Button(action: {
                            if(commentText != "") {
                                onCommentSubmit(commentText,isAnonymous)
                                commentText = ""
                            }
                        }){
                            Text("올리기")
                                .padding(EdgeInsets(top: 6.5, leading: 11, bottom: 6.5, trailing: 11))
                                .background(Color.orange500)
                                .customFont(font: .text13(weight: .Bold))
                                .foregroundColor(.backgroundPrimary)
                                .cornerRadius(6)
                        }
                        .padding(6.5)
                    }
                )
        }
    }

    var anonymousButton: some View {
        Toggle(isOn: $isAnonymous) {
            Text("익명")
                .customFont(font: .text12(weight: .ExtraBold))
                .foregroundStyle(Color.orange500)
        }
        .toggleStyle(CustomCheckboxStyle())
        .onChange(of: isAnonymous) { newValue in
            UserDefaults.standard.set(newValue, forKey: "isAnonymous")
        }
    }
    struct CustomCheckboxStyle: ToggleStyle {
        func makeBody(configuration: Configuration) -> some View {
            HStack(spacing: 5) {
                    if configuration.isOn {
                        Image("CheckboxTicked")
                            .frame(width: 13, height: 13)
                    } else {
                        Image("Checkbox")
                            .frame(width: 13, height: 13)
                    }
                
                configuration.label
                    .foregroundColor(.orange500)
            }
            .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
            .contentShape(Rectangle())
            .onTapGesture {
                configuration.isOn.toggle()
            }
        }
    }
}

struct CommunityReplyBar_Previews: PreviewProvider {
    static var previews: some View {
        CommunityReplyBar(onCommentSubmit: { commentText,isAnonymous in
            print("Comment submitted: \(commentText)\nisAnonymous: \(isAnonymous)")
        })
    }
}
